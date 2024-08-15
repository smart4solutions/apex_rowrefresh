create or replace package body apx_plg_rowrefresh_pkg is

  -- Author  : JKIESEBRINK
  -- Created : 7/27/2024 12:26:12 AM
  -- Purpose : Oracle APEX Dynamic Action Plug-in

  -- Public function and procedure declarations
  function init(p_dynamic_action in apex_plugin.t_dynamic_action
               ,p_plugin         in apex_plugin.t_plugin) return apex_plugin.t_dynamic_action_render_result is
    l_render_result apex_plugin.t_dynamic_action_render_result;
  begin
    l_render_result.javascript_function := 's4s.apex.rowrefresh.init';
    l_render_result.ajax_identifier     := apex_plugin.get_ajax_identifier;
    l_render_result.attribute_01        := p_dynamic_action.attribute_01; -- jQuery Selector
    l_render_result.attribute_02        := p_dynamic_action.attribute_02; -- Template Name
    l_render_result.attribute_03        := p_dynamic_action.attribute_03; -- Source: SQL Query
    l_render_result.attribute_04        := p_dynamic_action.attribute_04; -- Source: Items to submit
    l_render_result.attribute_05        := p_dynamic_action.attribute_05; -- Row Identifier
  
    return l_render_result;
  exception
    when others then
      apex_debug.error('Error in init: ' || sqlerrm);
      raise;
  end init;

  function fetch_cursor_data(i_cursor in out sys_refcursor) return tt_col_type is
    l_cursor_id    number;
    l_cursor_desc  dbms_sql.desc_tab;
    l_col_count    number;
    l_column_value varchar2(4000 char);
    l_column_map   tt_col_type := new tt_col_type();
  begin
    l_cursor_id := dbms_sql.to_cursor_number(rc => i_cursor);
    dbms_sql.describe_columns(c       => l_cursor_id
                             ,col_cnt => l_col_count
                             ,desc_t  => l_cursor_desc);
  
    <<define_columns_loop>>
    for i in 1 .. l_col_count
    loop
      dbms_sql.define_column(c           => l_cursor_id
                            ,position    => i
                            ,column      => l_column_value
                            ,column_size => 4000);
    end loop define_columns_loop;
  
    <<fetch_rows_loop>>
    while dbms_sql.fetch_rows(c => l_cursor_id) > 0
    loop
      <<process_columns_loop>>
      for i in 1 .. l_col_count
      loop
        dbms_sql.column_value(c        => l_cursor_id
                             ,position => i
                             ,value    => l_column_value);
        l_column_map(l_cursor_desc(i).col_name) := l_column_value;
      end loop process_columns_loop;
    end loop fetch_rows_loop;
  
    return l_column_map;
  exception
    when others then
      apex_debug.error('Error in fetch_cursor_data: ' || sqlerrm);
      raise;
  end fetch_cursor_data;

  function replace_template_vars(i_column_map in tt_col_type
                                ,i_template   in clob) return clob is
    l_result clob := i_template;
    l_var    varchar2(1000 char);
  begin
    l_var := i_column_map.first;
  
    <<replace_vars_loop>>
    while l_var is not null
    loop
      l_result := replace(srcstr => l_result
                         ,oldsub => '#' || upper(l_var) || '#'
                         ,newsub => i_column_map(l_var));
      l_var    := i_column_map.next(l_var);
    end loop replace_vars_loop;
  
    return l_result;
  exception
    when others then
      apex_debug.error('Error in replace_template_vars: ' || sqlerrm);
      raise;
  end replace_template_vars;

  function evaluate_condition(i_condition  in varchar2
                             ,i_column_map in tt_col_type) return boolean is
    l_cond      varchar2(4000 char);
    l_result    boolean;
    l_cursor_id integer;
    l_dummy     integer;
    l_var_name  varchar2(1000 char);
  begin
    if i_condition is null
    then
      return true;
    end if;
  
    -- Substitute variables in the condition
    l_cond := replace_template_vars(i_column_map => i_column_map
                                   ,i_template   => i_condition);
  
    -- Prepare dynamic SQL for the condition
    l_cursor_id := dbms_sql.open_cursor;
    dbms_sql.parse(c             => l_cursor_id
                  ,statement     => 'BEGIN :result := (' || l_cond || '); END;'
                  ,language_flag => dbms_sql.native);
    dbms_sql.bind_variable(c     => l_cursor_id
                          ,name  => ':result'
                          ,value => l_result);
  
    -- Bind variables in the condition string
    <<bind_variables_loop>>
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
                                        when i_column_map.exists(l_var_name) then
                                         i_column_map(l_var_name)
                                        else
                                         null
                                      end);
    end loop bind_variables_loop;
  
    l_dummy := dbms_sql.execute(c => l_cursor_id);
    dbms_sql.variable_value(c     => l_cursor_id
                           ,name  => ':result'
                           ,value => l_result);
    dbms_sql.close_cursor(c => l_cursor_id);
  
    return l_result;
  exception
    when others then
      apex_debug.error('Error in evaluate_condition: ' || sqlerrm);
      raise;
  end evaluate_condition;

  function get_template(i_template_name in varchar2
                       ,i_column_map    in tt_col_type) return clob is
    l_template clob;
  begin
    <<template_search_loop>>
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
      if evaluate_condition(i_condition  => r_temp.col_template_condition1
                           ,i_column_map => i_column_map)
      then
        l_template := r_temp.col_template1;
      elsif evaluate_condition(i_condition  => r_temp.col_template_condition2
                              ,i_column_map => i_column_map)
      then
        l_template := r_temp.col_template2;
      elsif evaluate_condition(i_condition  => r_temp.col_template_condition3
                              ,i_column_map => i_column_map)
      then
        l_template := r_temp.col_template3;
      elsif evaluate_condition(i_condition  => r_temp.col_template_condition4
                              ,i_column_map => i_column_map)
      then
        l_template := r_temp.col_template4;
      end if;
    end loop template_search_loop;
  
    return l_template;
  exception
    when others then
      apex_debug.error('Error in get_template: ' || sqlerrm);
      raise;
  end get_template;

  function refresh_row(p_dynamic_action in apex_plugin.t_dynamic_action
                      ,p_plugin         in apex_plugin.t_plugin) return apex_plugin.t_dynamic_action_ajax_result is
    l_ajax_result apex_plugin.t_dynamic_action_ajax_result;
    l_cursor_id   number;
    l_cursor      sys_refcursor;
    l_page_items  apex_application_global.vc_arr2;
    l_dummy       number;
    l_column_map  tt_col_type;
    l_row_html    clob;
    l_template    clob;
  begin
    -- Open the cursor for the selected row
    l_cursor_id := dbms_sql.open_cursor;
    dbms_sql.parse(c             => l_cursor_id
                  ,statement     => p_dynamic_action.attribute_03
                  ,language_flag => dbms_sql.native);
  
    -- Parse the list of page items to submit
    l_page_items := apex_util.string_to_table(p_string => p_dynamic_action.attribute_04);
  
    -- Bind each page item value to the cursor
    <<bind_page_items_loop>>
    for i in 1 .. l_page_items.count
    loop
      dbms_sql.bind_variable(c     => l_cursor_id
                            ,name  => l_page_items(i)
                            ,value => v(l_page_items(i)));
    end loop bind_page_items_loop;
  
    l_dummy := dbms_sql.execute(c => l_cursor_id);
  
    -- Get cursor data as key-value pairs
    l_cursor     := dbms_sql.to_refcursor(cursor_number => l_cursor_id);
    l_column_map := fetch_cursor_data(i_cursor => l_cursor);
  
    -- Get the appropriate template
    l_template := get_template(i_template_name => p_dynamic_action.attribute_02
                              ,i_column_map    => l_column_map);
  
    -- Replace template variables with values from key-value pairs
    l_row_html := replace_template_vars(i_column_map => l_column_map
                                       ,i_template   => l_template);
  
    -- Write the result as JSON
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
  
    return l_ajax_result;
  exception
    when others then
      apex_debug.error('Error in refresh_row: ' || sqlerrm);
      raise;
  end refresh_row;

end apx_plg_rowrefresh_pkg;
/
