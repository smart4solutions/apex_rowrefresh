prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- Oracle APEX export file
--
-- You should run this script using a SQL client connected to the database as
-- the owner (parsing schema) of the application or as a database user with the
-- APEX_ADMINISTRATOR_ROLE role.
--
-- This export file has been automatically generated. Modifying this file is not
-- supported by Oracle and can lead to unexpected application and/or instance
-- behavior now or in the future.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_imp.import_begin (
 p_version_yyyy_mm_dd=>'2024.05.31'
,p_release=>'24.1.3'
,p_default_workspace_id=>36728649485285263261
,p_default_application_id=>30848
,p_default_id_offset=>38628925294141333017
,p_default_owner=>'SMART4SOLUTIONS'
);
end;
/
 
prompt APPLICATION 30848 - smart4solutions
--
-- Application Export:
--   Application:     30848
--   Name:            smart4solutions
--   Date and Time:   15:33 Wednesday August 21, 2024
--   Exported By:     JKIESEBRINK@SMART4SOLUTIONS.NL
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 63247786901976561
--   Manifest End
--   Version:         24.1.3
--   Instance ID:     63113759365424
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/dynamic_action/nl_smart4solutions_rowrefresh
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(63247786901976561)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'NL_SMART4SOLUTIONS_ROWREFRESH'
,p_display_name=>'SMART4Solutions Rowrefresh'
,p_category=>'EXECUTE'
,p_javascript_file_urls=>'#PLUGIN_FILES#main#MIN#.js'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'  -- Author  : JKIESEBRINK',
'  -- Created : 7/27/2024 12:26:12 AM',
'  -- Purpose : Oracle APEX Dynamic Action Plug-in',
'',
'  -- Public type declarations',
'  type tt_col_type is table of varchar2(4000) index by varchar2(1000);',
'',
'  -- Public function and procedure declarations',
'  function init(p_dynamic_action in apex_plugin.t_dynamic_action',
'               ,p_plugin         in apex_plugin.t_plugin) return apex_plugin.t_dynamic_action_render_result is',
'    l_render_result apex_plugin.t_dynamic_action_render_result;',
'  begin',
'    l_render_result.javascript_function := ''s4s.apex.rowrefresh.init'';',
'    l_render_result.ajax_identifier     := apex_plugin.get_ajax_identifier;',
'    l_render_result.attribute_01        := p_dynamic_action.attribute_01; -- jQuery Selector',
'    l_render_result.attribute_02        := p_dynamic_action.attribute_02; -- Template Name',
'    l_render_result.attribute_03        := p_dynamic_action.attribute_03; -- Source: SQL Query',
'    l_render_result.attribute_04        := p_dynamic_action.attribute_04; -- Source: Items to submit',
'    l_render_result.attribute_05        := p_dynamic_action.attribute_05; -- Row Identifier',
'    l_render_result.attribute_06        := p_dynamic_action.attribute_06; -- Show Spinner',
'  ',
'    return l_render_result;',
'  exception',
'    when others then',
'      apex_debug.error(''Error in init: '' || sqlerrm);',
'      raise;',
'  end init;',
'',
'  function fetch_cursor_data(i_cursor in out sys_refcursor) return tt_col_type is',
'    l_cursor_id    number;',
'    l_cursor_desc  dbms_sql.desc_tab;',
'    l_col_count    number;',
'    l_column_value varchar2(4000 char);',
'    l_column_map   tt_col_type := new tt_col_type();',
'  begin',
'    l_cursor_id := dbms_sql.to_cursor_number(rc => i_cursor);',
'    dbms_sql.describe_columns(c       => l_cursor_id',
'                             ,col_cnt => l_col_count',
'                             ,desc_t  => l_cursor_desc);',
'  ',
'    <<define_columns_loop>>',
'    for i in 1 .. l_col_count',
'    loop',
'      dbms_sql.define_column(c           => l_cursor_id',
'                            ,position    => i',
'                            ,column      => l_column_value',
'                            ,column_size => 4000);',
'    end loop define_columns_loop;',
'  ',
'    <<fetch_rows_loop>>',
'    while dbms_sql.fetch_rows(c => l_cursor_id) > 0',
'    loop',
'      <<process_columns_loop>>',
'      for i in 1 .. l_col_count',
'      loop',
'        dbms_sql.column_value(c        => l_cursor_id',
'                             ,position => i',
'                             ,value    => l_column_value);',
'        l_column_map(l_cursor_desc(i).col_name) := l_column_value;',
'      end loop process_columns_loop;',
'    end loop fetch_rows_loop;',
'  ',
'    return l_column_map;',
'  exception',
'    when others then',
'      apex_debug.error(''Error in fetch_cursor_data: '' || sqlerrm);',
'      raise;',
'  end fetch_cursor_data;',
'',
'  function replace_template_vars(i_column_map in tt_col_type',
'                                ,i_template   in clob) return clob is',
'    l_result clob := i_template;',
'    l_var    varchar2(1000 char);',
'  begin',
'    l_var := i_column_map.first;',
'  ',
'    <<replace_vars_loop>>',
'    while l_var is not null',
'    loop',
'      l_result := replace(srcstr => l_result',
'                         ,oldsub => ''#'' || upper(l_var) || ''#''',
'                         ,newsub => i_column_map(l_var));',
'      l_var    := i_column_map.next(l_var);',
'    end loop replace_vars_loop;',
'  ',
'    return l_result;',
'  exception',
'    when others then',
'      apex_debug.error(''Error in replace_template_vars: '' || sqlerrm);',
'      raise;',
'  end replace_template_vars;',
'',
'  function evaluate_condition(i_condition  in varchar2',
'                             ,i_column_map in tt_col_type) return boolean is',
'    l_cond      varchar2(4000 char);',
'    l_result    boolean;',
'    l_cursor_id integer;',
'    l_dummy     integer;',
'    l_var_name  varchar2(1000 char);',
'  begin',
'    if i_condition is null',
'    then',
'      return true;',
'    end if;',
'  ',
'    -- Substitute variables in the condition',
'    l_cond := replace_template_vars(i_column_map => i_column_map',
'                                   ,i_template   => i_condition);',
'  ',
'    -- Prepare dynamic SQL for the condition',
'    l_cursor_id := dbms_sql.open_cursor;',
'    dbms_sql.parse(c             => l_cursor_id',
'                  ,statement     => ''BEGIN :result := ('' || l_cond || ''); END;''',
'                  ,language_flag => dbms_sql.native);',
'    dbms_sql.bind_variable(c     => l_cursor_id',
'                          ,name  => '':result''',
'                          ,value => l_result);',
'  ',
'    -- Bind variables in the condition string',
'    <<bind_variables_loop>>',
'    for r_bind in (select distinct regexp_substr(l_cond',
'                                                ,'':[^:() ,]+''',
'                                                ,1',
'                                                ,level) as var_name',
'                   from   dual',
'                   connect by regexp_substr(l_cond',
'                                           ,'':[^:() ,]+''',
'                                           ,1',
'                                           ,level) is not null)',
'    loop',
'      l_var_name := substr(r_bind.var_name',
'                          ,2);',
'      dbms_sql.bind_variable(c     => l_cursor_id',
'                            ,name  => r_bind.var_name',
'                            ,value => case',
'                                        when i_column_map.exists(l_var_name) then',
'                                         i_column_map(l_var_name)',
'                                        else',
'                                         null',
'                                      end);',
'    end loop bind_variables_loop;',
'  ',
'    l_dummy := dbms_sql.execute(c => l_cursor_id);',
'    dbms_sql.variable_value(c     => l_cursor_id',
'                           ,name  => '':result''',
'                           ,value => l_result);',
'    dbms_sql.close_cursor(c => l_cursor_id);',
'  ',
'    return l_result;',
'  exception',
'    when others then',
'      apex_debug.error(''Error in evaluate_condition: '' || sqlerrm);',
'      raise;',
'  end evaluate_condition;',
'',
'  function get_template(i_template_name in varchar2',
'                       ,i_column_map    in tt_col_type) return clob is',
'    l_template clob;',
'  begin',
'    <<template_search_loop>>',
'    for r_temp in (select temp.col_template1',
'                         ,temp.col_template_condition1',
'                         ,temp.col_template2',
'                         ,temp.col_template_condition2',
'                         ,temp.col_template3',
'                         ,temp.col_template_condition3',
'                         ,temp.col_template4',
'                         ,temp.col_template_condition4',
'                   from   apex_application_temp_report temp',
'                   where  temp.template_name = i_template_name',
'                   and    temp.application_id = apex_application.g_flow_id)',
'    loop',
'      if evaluate_condition(i_condition  => r_temp.col_template_condition1',
'                           ,i_column_map => i_column_map)',
'      then',
'        l_template := r_temp.col_template1;',
'      elsif evaluate_condition(i_condition  => r_temp.col_template_condition2',
'                              ,i_column_map => i_column_map)',
'      then',
'        l_template := r_temp.col_template2;',
'      elsif evaluate_condition(i_condition  => r_temp.col_template_condition3',
'                              ,i_column_map => i_column_map)',
'      then',
'        l_template := r_temp.col_template3;',
'      elsif evaluate_condition(i_condition  => r_temp.col_template_condition4',
'                              ,i_column_map => i_column_map)',
'      then',
'        l_template := r_temp.col_template4;',
'      end if;',
'    end loop template_search_loop;',
'  ',
'    return l_template;',
'  exception',
'    when others then',
'      apex_debug.error(''Error in get_template: '' || sqlerrm);',
'      raise;',
'  end get_template;',
'',
'  function refresh_row(p_dynamic_action in apex_plugin.t_dynamic_action',
'                      ,p_plugin         in apex_plugin.t_plugin) return apex_plugin.t_dynamic_action_ajax_result is',
'    l_ajax_result apex_plugin.t_dynamic_action_ajax_result;',
'    l_cursor_id   number;',
'    l_cursor      sys_refcursor;',
'    l_page_items  apex_application_global.vc_arr2;',
'    l_dummy       number;',
'    l_column_map  tt_col_type;',
'    l_row_html    clob;',
'    l_template    clob;',
'  begin',
'    -- Open the cursor for the selected row',
'    l_cursor_id := dbms_sql.open_cursor;',
'    dbms_sql.parse(c             => l_cursor_id',
'                  ,statement     => p_dynamic_action.attribute_03',
'                  ,language_flag => dbms_sql.native);',
'  ',
'    -- Parse the list of page items to submit',
'    l_page_items := apex_util.string_to_table(p_string => p_dynamic_action.attribute_04);',
'  ',
'    -- Bind each page item value to the cursor',
'    <<bind_page_items_loop>>',
'    for i in 1 .. l_page_items.count',
'    loop',
'      dbms_sql.bind_variable(c     => l_cursor_id',
'                            ,name  => l_page_items(i)',
'                            ,value => v(l_page_items(i)));',
'    end loop bind_page_items_loop;',
'  ',
'    l_dummy := dbms_sql.execute(c => l_cursor_id);',
'  ',
'    -- Get cursor data as key-value pairs',
'    l_cursor     := dbms_sql.to_refcursor(cursor_number => l_cursor_id);',
'    l_column_map := fetch_cursor_data(i_cursor => l_cursor);',
'  ',
'    -- Get the appropriate template',
'    l_template := get_template(i_template_name => p_dynamic_action.attribute_02',
'                              ,i_column_map    => l_column_map);',
'  ',
'    -- Replace template variables with values from key-value pairs',
'    l_row_html := replace_template_vars(i_column_map => l_column_map',
'                                       ,i_template   => l_template);',
'  ',
'    -- Write the result as JSON',
'    apex_json.open_object;',
'    apex_json.write(p_name  => ''jquery_selector''',
'                   ,p_value => p_dynamic_action.attribute_01);',
'    apex_json.write(p_name  => ''template_name''',
'                   ,p_value => p_dynamic_action.attribute_02);',
'    apex_json.write(p_name  => ''source_query''',
'                   ,p_value => p_dynamic_action.attribute_03);',
'    apex_json.write(p_name  => ''items_to_submit''',
'                   ,p_value => p_dynamic_action.attribute_04);',
'    apex_json.write(p_name  => ''row_identifier''',
'                   ,p_value => p_dynamic_action.attribute_05);',
'    apex_json.write(p_name       => ''row_html''',
'                   ,p_value      => l_row_html',
'                   ,p_write_null => true);',
'    apex_json.close_object;',
'  ',
'    return l_ajax_result;',
'  exception',
'    when others then',
'      apex_debug.error(''Error in refresh_row: '' || sqlerrm);',
'      raise;',
'  end refresh_row;',
''))
,p_api_version=>1
,p_render_function=>'init'
,p_ajax_function=>'refresh_row'
,p_standard_attributes=>'BUTTON:REGION:JQUERY_SELECTOR:TRIGGERING_ELEMENT:REQUIRED:ONLOAD:STOP_EXECUTION_ON_ERROR:WAIT_FOR_RESULT'
,p_substitute_attributes=>true
,p_version_scn=>15556163867099
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'1.1.1'
,p_about_url=>'https://apex.oracle.com/pls/apex/r/s4s/smart4solutions/apex_rowrefresh'
,p_files_version=>157
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(63386944894667200)
,p_plugin_id=>wwv_flow_imp.id(63247786901976561)
,p_title=>'Source'
,p_display_sequence=>1
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(63267918602376517)
,p_plugin_id=>wwv_flow_imp.id(63247786901976561)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Row Selector (jQuery Selector)'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_examples=>'tr[data-row-id]'
,p_help_text=>'A jQuery selector that targets the row closest to the triggering element. The plug-in searches for the first occurrence of this selector starting from the triggering element.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(63268632303377896)
,p_plugin_id=>wwv_flow_imp.id(63247786901976561)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>30
,p_prompt=>'Template Name'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_examples=>'My Custom Template'
,p_help_text=>'The name of the template used for rendering the row. The correct row template is selected based on the evaluated PL/SQL expression (template condition).'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(63394637063760262)
,p_plugin_id=>wwv_flow_imp.id(63247786901976561)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>10
,p_prompt=>'SQL Query'
,p_attribute_type=>'SQL'
,p_is_required=>true
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(63386944894667200)
,p_examples=>'SELECT * FROM my_table WHERE id = :P1_ITEM1'
,p_help_text=>'A PL/SQL block that returns the specific row data. Ensure that all bind or substitution variables used in the template condition are part of this query.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(63924140399043710)
,p_plugin_id=>wwv_flow_imp.id(63247786901976561)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>20
,p_prompt=>'Items to Submit'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(63386944894667200)
,p_examples=>'P1_ITEM1,P1_ITEM2'
,p_help_text=>'A comma-separated list of page items to submit to the server for session state management. Ensure all necessary page items used in the query and conditions are included here.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(65190677420813128)
,p_plugin_id=>wwv_flow_imp.id(63247786901976561)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>20
,p_prompt=>'Row Identifier'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_examples=>'P1_ITEM1'
,p_help_text=>'The name of the page-item used for identifying the row. The plug-in will go through all data attributes of the matched items for the jQuery Selector to identify the correct row.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(26469965133964021317)
,p_plugin_id=>wwv_flow_imp.id(63247786901976561)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Show Spinner'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(65190677420813128)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_NULL'
,p_help_text=>'Shows a spinner on the matched element before replacing the identified row, removes it when it''s replaced. Only possible when `Row Indentifier` is provided.'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(63255301228159229)
,p_plugin_id=>wwv_flow_imp.id(63247786901976561)
,p_name=>'after_refresh'
,p_display_name=>'Ajax Callback for Refresh Row'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '76617220733473203D20733473207C7C207B7D0A7334732E61706578203D207334732E61706578207C7C207B7D3B0A0A7334732E617065782E726F7772656672657368203D207B0A202020202F2F20496E697469616C697A6520746865206D6F64756C65';
wwv_flow_imp.g_varchar2_table(2) := '0A2020202027696E6974273A2066756E6374696F6E202829207B0A20202020202020207334732E617065782E726F77726566726573682E68616E646C654368616E676528746869732E616374696F6E2C20746869732E74726967676572696E67456C656D';
wwv_flow_imp.g_varchar2_table(3) := '656E74293B0A202020207D2C0A0A202020202F2F2048616E646C6520746865206368616E6765206576656E740A202020202768616E646C654368616E6765273A2066756E6374696F6E2028616374696F6E2C20656C656D656E7429207B0A202020202020';
wwv_flow_imp.g_varchar2_table(4) := '20206C657420656C656D656E7453656C6563746F72203D20616374696F6E2E61747472696275746530313B0A20202020202020206C657420726F774964656E746966696572203D20617065782E6974656D28616374696F6E2E6174747269627574653035';
wwv_flow_imp.g_varchar2_table(5) := '292E67657456616C756528293B0A20202020202020206C65742073686F775370696E6E6572203D20616374696F6E2E61747472696275746530363B0A20202020202020206C6574207370696E6E6572456C656D656E742C206D617463686564456C656D65';
wwv_flow_imp.g_varchar2_table(6) := '6E742C206D617463686564417474726962757465203D206E756C6C3B0A0A20202020202020202F2F20436F6E76657274207468652070616765206974656D732061747472696275746520746F20612073656C6563746F7220737472696E670A2020202020';
wwv_flow_imp.g_varchar2_table(7) := '2020206C657420706167654974656D7353656C6563746F72203D20616374696F6E2E61747472696275746530340A2020202020202020202020202E73706C697428272C27290A2020202020202020202020202E6D61702866756E6374696F6E2028697465';
wwv_flow_imp.g_varchar2_table(8) := '6D29207B2072657475726E20272327202B206974656D2E7472696D28293B207D290A2020202020202020202020202E6A6F696E28272C27293B0A0A2020202020202020636F6E736F6C652E6465627567282768616E646C654368616E67653A207375626D';
wwv_flow_imp.g_varchar2_table(9) := '697474696E672070616765206974656D73272C20706167654974656D7353656C6563746F72293B0A0A202020202020202069662028726F774964656E74696669657229207B0A2020202020202020202020202F2F2049746572617465206F766572206561';
wwv_flow_imp.g_varchar2_table(10) := '6368206D61746368696E6720656C656D656E74207768656E2074686520726F77206964656E74696669657220697320617661696C61626C650A202020202020202020202020646F63756D656E742E717565727953656C6563746F72416C6C28656C656D65';
wwv_flow_imp.g_varchar2_table(11) := '6E7453656C6563746F72292E666F72456163682866756E6374696F6E2028656C656D656E7429207B0A202020202020202020202020202020202F2F204C6F6F70207468726F75676820616C6C2064617461206174747269627574657320746F2066696E64';
wwv_flow_imp.g_varchar2_table(12) := '2061206D617463680A20202020202020202020202020202020666F7220286C65742061747472206F6620656C656D656E742E6174747269627574657329207B0A202020202020202020202020202020202020202069662028617474722E6E616D652E7374';
wwv_flow_imp.g_varchar2_table(13) := '61727473576974682827646174612D272920262620617474722E76616C7565203D3D3D20726F774964656E74696669657229207B0A2020202020202020202020202020202020202020202020206D617463686564456C656D656E74203D20656C656D656E';
wwv_flow_imp.g_varchar2_table(14) := '743B0A2020202020202020202020202020202020202020202020206D617463686564417474726962757465203D20617474722E6E616D653B0A20202020202020202020202020202020202020202020202072657475726E20747275653B20202F2F204272';
wwv_flow_imp.g_varchar2_table(15) := '65616B7320746865206C6F6F700A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D0A2020202020202020202020207D293B0A0A2020202020202020202020206966202873686F775370696E6E6572203D';
wwv_flow_imp.g_varchar2_table(16) := '3D3D2027592729207B0A202020202020202020202020202020206C65742073656C6563746F72203D206D617463686564456C656D656E74203F20602E247B6D617463686564456C656D656E742E636C6173734C6973745B305D7D5B247B6D617463686564';
wwv_flow_imp.g_varchar2_table(17) := '4174747269627574657D3D22247B726F774964656E7469666965727D225D60203A206E756C6C3B0A20202020202020202020202020202020636F6E736F6C652E6465627567282768616E646C654368616E67653A206170706C79207370696E6E6572206F';
wwv_flow_imp.g_varchar2_table(18) := '6E272C2073656C6563746F72293B0A0A202020202020202020202020202020207370696E6E6572456C656D656E74203D20617065782E7574696C2E73686F775370696E6E65722873656C6563746F72293B0A2020202020202020202020207D0A20202020';
wwv_flow_imp.g_varchar2_table(19) := '202020207D20656C7365207B0A2020202020202020202020202F2F2046616C6C6261636B20746F2074686520636C6F73657374206D61746368696E6720656C656D656E74206966206E6F206964656E7469666965722069732070726F76696465640A2020';
wwv_flow_imp.g_varchar2_table(20) := '202020202020202020206D617463686564456C656D656E74203D20656C656D656E742E636C6F7365737428656C656D656E7453656C6563746F72293B0A20202020202020207D0A0A2020202020202020696620286D617463686564456C656D656E742920';
wwv_flow_imp.g_varchar2_table(21) := '7B0A2020202020202020202020202F2F204D616B6520616E20414A41582063616C6C20746F2066657463682074686520646174610A2020202020202020202020207334732E617065782E726F77726566726573682E6665746368526F7744617461286163';
wwv_flow_imp.g_varchar2_table(22) := '74696F6E2E616A61784964656E7469666965722C20706167654974656D7353656C6563746F72292E7468656E2866756E6374696F6E20286461746129207B0A202020202020202020202020202020202F2F204164642061706578206576656E7420666F72';
wwv_flow_imp.g_varchar2_table(23) := '207375636365737366756C20726566726573680A20202020202020202020202020202020617065782E6576656E742E74726967676572286D617463686564456C656D656E742C202761667465725F7265667265736827293B0A0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(24) := '2020202020202F2F205265706C6163652074686520656C656D656E74207769746820746865206E657720646174610A202020202020202020202020202020206D617463686564456C656D656E742E6F7574657248544D4C203D20646174612E726F775F68';
wwv_flow_imp.g_varchar2_table(25) := '746D6C3B0A2020202020202020202020207D292E63617463682866756E6374696F6E20286572726F7229207B0A20202020202020202020202020202020636F6E736F6C652E6572726F7228274572726F72206665746368696E6720726F7720646174613A';
wwv_flow_imp.g_varchar2_table(26) := '272C206572726F72293B0A2020202020202020202020207D292E66696E616C6C792866756E6374696F6E202829207B0A202020202020202020202020202020206966202873686F775370696E6E6572203D3D3D20275927202626207370696E6E6572456C';
wwv_flow_imp.g_varchar2_table(27) := '656D656E7429207B0A20202020202020202020202020202020202020207370696E6E6572456C656D656E742E72656D6F766528293B0A202020202020202020202020202020207D0A2020202020202020202020207D293B0A20202020202020207D20656C';
wwv_flow_imp.g_varchar2_table(28) := '7365207B0A202020202020202020202020636F6E736F6C652E6572726F722827456C656D656E74206E6F7420666F756E6420666F722073656C6563746F723A20272C20656C656D656E7453656C6563746F72293B0A20202020202020207D0A202020207D';
wwv_flow_imp.g_varchar2_table(29) := '2C0A0A202020202F2F2046657463682074686520726F772064617461207573696E6720414A41580A20202020276665746368526F7744617461273A2066756E6374696F6E2028616A61784964656E7469666965722C20706167654974656D7329207B0A20';
wwv_flow_imp.g_varchar2_table(30) := '2020202020202072657475726E206E65772050726F6D6973652866756E6374696F6E20287265736F6C76652C2072656A65637429207B0A202020202020202020202020617065782E7365727665722E706C7567696E28616A61784964656E746966696572';
wwv_flow_imp.g_varchar2_table(31) := '2C207B0A20202020202020202020202020202020706167654974656D733A20706167654974656D730A2020202020202020202020207D2C207B0A20202020202020202020202020202020737563636573733A2066756E6374696F6E20286461746129207B';
wwv_flow_imp.g_varchar2_table(32) := '0A20202020202020202020202020202020202020207265736F6C76652864617461293B0A202020202020202020202020202020207D2C0A202020202020202020202020202020206572726F723A2066756E6374696F6E20286572726F7229207B0A202020';
wwv_flow_imp.g_varchar2_table(33) := '202020202020202020202020202020202072656A656374286572726F72293B0A202020202020202020202020202020207D0A2020202020202020202020207D293B0A20202020202020207D293B0A202020207D0A7D0A';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(63255698796196839)
,p_plugin_id=>wwv_flow_imp.id(63247786901976561)
,p_file_name=>'main.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '766172207334733D7334737C7C7B7D3B7334732E617065783D7334732E617065787C7C7B7D2C7334732E617065782E726F77726566726573683D7B696E69743A66756E6374696F6E28297B7334732E617065782E726F77726566726573682E68616E646C';
wwv_flow_imp.g_varchar2_table(2) := '654368616E676528746869732E616374696F6E2C746869732E74726967676572696E67456C656D656E74297D2C68616E646C654368616E67653A66756E6374696F6E28652C74297B6C6574206E2C722C613D652E61747472696275746530312C6F3D6170';
wwv_flow_imp.g_varchar2_table(3) := '65782E6974656D28652E6174747269627574653035292E67657456616C756528292C693D652E61747472696275746530362C733D6E756C6C2C6C3D652E61747472696275746530342E73706C697428222C22292E6D6170282866756E6374696F6E286529';
wwv_flow_imp.g_varchar2_table(4) := '7B72657475726E2223222B652E7472696D28297D29292E6A6F696E28222C22293B696628636F6E736F6C652E6465627567282268616E646C654368616E67653A207375626D697474696E672070616765206974656D73222C6C292C6F297B696628646F63';
wwv_flow_imp.g_varchar2_table(5) := '756D656E742E717565727953656C6563746F72416C6C2861292E666F7245616368282866756E6374696F6E2865297B666F72286C65742074206F6620652E6174747269627574657329696628742E6E616D652E737461727473576974682822646174612D';
wwv_flow_imp.g_varchar2_table(6) := '22292626742E76616C75653D3D3D6F2972657475726E20723D652C733D742E6E616D652C21307D29292C2259223D3D3D69297B6C657420653D723F602E247B722E636C6173734C6973745B305D7D5B247B737D3D22247B6F7D225D603A6E756C6C3B636F';
wwv_flow_imp.g_varchar2_table(7) := '6E736F6C652E6465627567282268616E646C654368616E67653A206170706C79207370696E6E6572206F6E222C65292C6E3D617065782E7574696C2E73686F775370696E6E65722865297D7D656C736520723D742E636C6F736573742861293B723F7334';
wwv_flow_imp.g_varchar2_table(8) := '732E617065782E726F77726566726573682E6665746368526F774461746128652E616A61784964656E7469666965722C6C292E7468656E282866756E6374696F6E2865297B617065782E6576656E742E7472696767657228722C2261667465725F726566';
wwv_flow_imp.g_varchar2_table(9) := '7265736822292C722E6F7574657248544D4C3D652E726F775F68746D6C7D29292E6361746368282866756E6374696F6E2865297B636F6E736F6C652E6572726F7228224572726F72206665746368696E6720726F7720646174613A222C65297D29292E66';
wwv_flow_imp.g_varchar2_table(10) := '696E616C6C79282866756E6374696F6E28297B2259223D3D3D6926266E26266E2E72656D6F766528297D29293A636F6E736F6C652E6572726F722822456C656D656E74206E6F7420666F756E6420666F722073656C6563746F723A20222C61297D2C6665';
wwv_flow_imp.g_varchar2_table(11) := '746368526F77446174613A66756E6374696F6E28652C74297B72657475726E206E65772050726F6D697365282866756E6374696F6E286E2C72297B617065782E7365727665722E706C7567696E28652C7B706167654974656D733A747D2C7B7375636365';
wwv_flow_imp.g_varchar2_table(12) := '73733A66756E6374696F6E2865297B6E2865297D2C6572726F723A66756E6374696F6E2865297B722865297D7D297D29297D7D3B';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(26486129322812400297)
,p_plugin_id=>wwv_flow_imp.id(63247786901976561)
,p_file_name=>'main.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_imp.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false)
);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
