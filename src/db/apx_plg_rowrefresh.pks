create or replace package apx_plg_rowrefresh_pkg is

  -- Author  : JKIESEBRINK
  -- Created : 7/27/2024 12:26:12 AM
  -- Purpose : Oracle APEX Dynamic Action Plug-in

  -- Public type declarations
  type tt_col_type is table of varchar2(4000) index by varchar2(1000);

  -- Public function and procedure declarations
  function init(p_dynamic_action in apex_plugin.t_dynamic_action
               ,p_plugin         in apex_plugin.t_plugin) return apex_plugin.t_dynamic_action_render_result;

  function fetch_cursor_data(i_cursor in out sys_refcursor) return tt_col_type;

  function replace_template_vars(i_column_map in tt_col_type
                                ,i_template   in clob) return clob;

  function evaluate_condition(i_condition  in varchar2
                             ,i_column_map in tt_col_type) return boolean;

  function get_template(i_template_name in varchar2
                       ,i_column_map    in tt_col_type) return clob;

  function refresh_row(p_dynamic_action in apex_plugin.t_dynamic_action
                      ,p_plugin         in apex_plugin.t_plugin) return apex_plugin.t_dynamic_action_ajax_result;

end apx_plg_rowrefresh_pkg;
/
