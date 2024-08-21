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
    l_render_result.attribute_06        := p_dynamic_action.attribute_06; -- Show Spinner
    l_render_result.attribute_07        := p_dynamic_action.attribute_07; -- Region Static ID
  
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
    l_html clob := i_template;
    l_var  varchar2(1000 char);
  begin
    l_var := i_column_map.first;
  
    <<replace_vars_loop>>
    while l_var is not null
    loop
      l_html := replace(srcstr => l_html
                       ,oldsub => '#' || upper(l_var) || '#'
                       ,newsub => i_column_map(l_var));
      l_var  := i_column_map.next(l_var);
    end loop replace_vars_loop;
  
    return l_html;
  exception
    when others then
      apex_debug.error('Error in replace_template_vars: ' || sqlerrm);
      raise;
  end replace_template_vars;

  function apply_column_templates(i_column_map in tt_col_type
                                 ,i_template   in clob
                                 ,i_static_id  in varchar2) return clob is
    cursor c_cols(cp_static_id in varchar2) is
      select cols.column_alias
            ,cols.html_expression
      from   apex_application_page_rpt_cols cols
      join   apex_application_page_regions regs on regs.region_id = cols.region_id
      where  regs.static_id = cp_static_id
      and    cols.application_id = apex_application.g_flow_id
      and    cols.page_id = apex_application.g_flow_step_id;
  
    l_html_expr_map tt_col_type := new tt_col_type();
  begin
    <<replace_expression_loop>>
    for r_column in c_cols(cp_static_id => i_static_id)
    loop
      l_html_expr_map(r_column.column_alias) := replace_template_vars(i_column_map => i_column_map
                                                                     ,i_template   => coalesce(r_column.html_expression
                                                                                              ,i_column_map(r_column.column_alias)));
    end loop replace_expression_loop;
  
    return replace_template_vars(i_column_map => l_html_expr_map
                                ,i_template   => i_template);
  exception
    when others then
      apex_debug.error('Error in apply_column_templates: ' || sqlerrm);
      raise;
  end apply_column_templates;

  function evaluate_template_condition(i_condition  in varchar2
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
  end evaluate_template_condition;

  function get_template(i_template_name in varchar2
                       ,i_column_map    in tt_col_type) return clob is
    cursor c_temp(cp_template_name in varchar2) is
      select temp.col_template1
            ,temp.col_template_condition1
            ,temp.col_template2
            ,temp.col_template_condition2
            ,temp.col_template3
            ,temp.col_template_condition3
            ,temp.col_template4
            ,temp.col_template_condition4
      from   apex_application_temp_report temp
      where  temp.template_name = i_template_name
      and    temp.application_id = apex_application.g_flow_id;
  
    r_template c_temp%rowtype;
    l_template clob;
  begin
    open c_temp(cp_template_name => i_template_name);
    fetch c_temp
      into r_template;
    close c_temp;
  
    if evaluate_template_condition(i_condition  => r_template.col_template_condition1
                                  ,i_column_map => i_column_map)
    then
      l_template := r_template.col_template1;
    elsif evaluate_template_condition(i_condition  => r_template.col_template_condition2
                                     ,i_column_map => i_column_map)
    then
      l_template := r_template.col_template2;
    elsif evaluate_template_condition(i_condition  => r_template.col_template_condition3
                                     ,i_column_map => i_column_map)
    then
      l_template := r_template.col_template3;
    elsif evaluate_template_condition(i_condition  => r_template.col_template_condition4
                                     ,i_column_map => i_column_map)
    then
      l_template := r_template.col_template4;
    end if;
  
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
    l_row_html := apply_column_templates(i_column_map => l_column_map
                                        ,i_template   => l_template
                                        ,i_static_id  => p_dynamic_action.attribute_07);
  
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
    apex_json.write(p_name  => 'show_spinner'
                   ,p_value => p_dynamic_action.attribute_06);
    apex_json.write(p_name  => 'region_static_id'
                   ,p_value => p_dynamic_action.attribute_07);
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
