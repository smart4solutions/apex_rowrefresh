create or replace package body apx_plg_rowrefresh_pkg is

  -- Author  : JKIESEBRINK
  -- Created : 7/27/2024 12:26:12 AM
  -- Purpose : Oracle APEX Dynamic Action Plug-in

  -- Public function and procedure declarations
  function fn_init(p_dynamic_action in apex_plugin.t_dynamic_action
                  ,p_plugin         in apex_plugin.t_plugin) return apex_plugin.t_dynamic_action_render_result as
    l_result apex_plugin.t_dynamic_action_render_result;
  begin
    l_result.javascript_function := 's4s.apex.rowrefresh.init';
    l_result.ajax_identifier     := apex_plugin.get_ajax_identifier;
    l_result.attribute_01        := p_dynamic_action.attribute_01; -- jQuery Selector
    l_result.attribute_02        := p_dynamic_action.attribute_02; -- Template Name
    l_result.attribute_03        := p_dynamic_action.attribute_03; -- Source: SQL Query
    l_result.attribute_04        := p_dynamic_action.attribute_04; -- Source: Items to submit
    l_result.attribute_05        := p_dynamic_action.attribute_05; -- Row Identifier
  
    return l_result;
  end fn_init;

  function fn_get_cursor_data(i_cursor in out sys_refcursor) return tt_col_type is
    l_cursor_id   number;
    l_cursor_desc dbms_sql.desc_tab;
    l_col_count   number;
    l_tmp_value   varchar2(4000);
    l_col_tab     tt_col_type := new tt_col_type();
  begin
    l_cursor_id := dbms_sql.to_cursor_number(rc => i_cursor);
    dbms_sql.describe_columns(c       => l_cursor_id
                             ,col_cnt => l_col_count
                             ,desc_t  => l_cursor_desc);
  
    for i in 1 .. l_col_count
    loop
      dbms_sql.define_column(c           => l_cursor_id
                            ,position    => i
                            ,column      => l_tmp_value
                            ,column_size => 4000);
    end loop;
  
    while dbms_sql.fetch_rows(c => l_cursor_id) > 0
    loop
      for i in 1 .. l_col_count
      loop
        dbms_sql.column_value(c        => l_cursor_id
                             ,position => i
                             ,value    => l_tmp_value);
        l_col_tab(l_cursor_desc(i).col_name) := l_tmp_value;
      end loop;
    end loop;
  
    return l_col_tab;
  end fn_get_cursor_data;

  function fn_replace_template_vars(i_col_tab  in tt_col_type
                                   ,i_template in clob) return clob is
    l_result clob := i_template;
    l_var    varchar2(1000 char);
  begin
    l_var := i_col_tab.first;
  
    <<substring_loop>>
    while l_var is not null
    loop
      l_result := replace(srcstr => l_result
                         ,oldsub => '#' || upper(l_var) || '#'
                         ,newsub => i_col_tab(l_var));
      l_var    := i_col_tab.next(l_var);
    end loop substring_loop;
  
    return l_result;
  end fn_replace_template_vars;

  function fn_evaluate_condition(i_condition in varchar2
                                ,i_col_tab   in tt_col_type) return boolean is
    l_cond      varchar2(4000);
    l_result    boolean;
    l_cursor_id integer;
    l_dummy     integer;
    l_var_name  varchar2(1000);
  begin
    if i_condition is null
    then
      return true;
    end if;
  
    -- Substitute variables in condition
    l_cond := fn_replace_template_vars(i_col_tab  => i_col_tab
                                      ,i_template => i_condition);
  
    -- Prepare dynamic SQL for the condition
    l_cursor_id := dbms_sql.open_cursor;
    dbms_sql.parse(c             => l_cursor_id
                  ,statement     => 'BEGIN :result := (' || l_cond || '); END;'
                  ,language_flag => dbms_sql.native);
    dbms_sql.bind_variable(c     => l_cursor_id
                          ,name  => ':result'
                          ,value => l_result);
  
    -- Handle all variables in the condition string
    for r_bind in (select distinct regexp_substr(l_cond
                                                ,':[^:() ,]+'
                                                ,1
                                                ,level) as var_name
                   from   dual
                   connect by regexp_substr(l_cond
                                           ,':[^:() ,]+'
                                           ,1
                                           ,level) is not null)
    loop
      l_var_name := substr(r_bind.var_name
                          ,2);
      dbms_sql.bind_variable(c     => l_cursor_id
                            ,name  => r_bind.var_name
                            ,value => case
                                        when i_col_tab.exists(l_var_name) then
                                         i_col_tab(l_var_name)
                                        else
                                         null
                                      end);
    end loop;
  
    l_dummy := dbms_sql.execute(c => l_cursor_id);
    dbms_sql.variable_value(c     => l_cursor_id
                           ,name  => ':result'
                           ,value => l_result);
    dbms_sql.close_cursor(c => l_cursor_id);
  
    return l_result;
  end fn_evaluate_condition;

  function fn_get_template(i_template_name in varchar2
                          ,i_col_tab       in tt_col_type) return clob is
    l_template clob;
  begin
    for r_temp in (select temp.col_template1
                         ,temp.col_template_condition1
                         ,temp.col_template2
                         ,temp.col_template_condition2
                         ,temp.col_template3
                         ,temp.col_template_condition3
                         ,temp.col_template4
                         ,temp.col_template_condition4
                   from   apex_application_temp_report temp
                   where  temp.template_name = i_template_name)
    loop
      if fn_evaluate_condition(i_condition => r_temp.col_template_condition1
                              ,i_col_tab   => i_col_tab)
      then
        l_template := r_temp.col_template1;
      elsif fn_evaluate_condition(i_condition => r_temp.col_template_condition2
                                 ,i_col_tab   => i_col_tab)
      then
        l_template := r_temp.col_template2;
      elsif fn_evaluate_condition(i_condition => r_temp.col_template_condition3
                                 ,i_col_tab   => i_col_tab)
      then
        l_template := r_temp.col_template3;
      elsif fn_evaluate_condition(i_condition => r_temp.col_template_condition4
                                 ,i_col_tab   => i_col_tab)
      then
        l_template := r_temp.col_template4;
      end if;
    end loop;
  
    return l_template;
  end fn_get_template;

  function fn_refresh_row(p_dynamic_action in apex_plugin.t_dynamic_action
                         ,p_plugin         in apex_plugin.t_plugin) return apex_plugin.t_dynamic_action_ajax_result as
    l_result     apex_plugin.t_dynamic_action_ajax_result;
    l_cursor_id  number;
    l_cursor     sys_refcursor;
    l_page_items apex_application_global.vc_arr2;
    l_dummy      number;
    l_key_value  tt_col_type;
    l_row_html   clob;
    l_template   clob;
  begin
    -- Open the cursor for the selected row
    l_cursor_id := dbms_sql.open_cursor;
    dbms_sql.parse(c             => l_cursor_id
                  ,statement     => p_dynamic_action.attribute_03
                  ,language_flag => dbms_sql.native);
  
    -- Parse the list of page items to submit
    l_page_items := apex_util.string_to_table(p_string => p_dynamic_action.attribute_04);
  
    -- Loop over each page item, fetch its value from session state, and bind it
    for i in 1 .. l_page_items.count
    loop
      dbms_sql.bind_variable(c     => l_cursor_id
                            ,name  => l_page_items(i)
                            ,value => v(l_page_items(i)));
    end loop;
  
    l_dummy := dbms_sql.execute(c => l_cursor_id);
  
    -- Use the function to get cursor data as key-value pairs
    l_cursor    := dbms_sql.to_refcursor(cursor_number => l_cursor_id);
    l_key_value := fn_get_cursor_data(i_cursor => l_cursor);
  
    -- Get the correct template
    l_template := fn_get_template(i_template_name => p_dynamic_action.attribute_02
                                 ,i_col_tab       => l_key_value);
  
    -- Replace the template variables with values from key-value pairs
    l_row_html := fn_replace_template_vars(i_col_tab  => l_key_value
                                          ,i_template => l_template);
  
    apex_json.open_object;
    apex_json.write(p_name  => 'jquery_selector'
                   ,p_value => p_dynamic_action.attribute_01);
    apex_json.write(p_name  => 'template_name'
                   ,p_value => p_dynamic_action.attribute_02);
    apex_json.write(p_name  => 'source_query'
                   ,p_value => p_dynamic_action.attribute_03);
    apex_json.write(p_name  => 'items_to_submit'
                   ,p_value => p_dynamic_action.attribute_04);
    apex_json.write(p_name  => 'row_identifier'
                   ,p_value => p_dynamic_action.attribute_05);
    apex_json.write(p_name       => 'row_html'
                   ,p_value      => l_row_html
                   ,p_write_null => true);
    apex_json.close_object;
  
    return l_result;
  end fn_refresh_row;

end apx_plg_rowrefresh_pkg;
/
