<master src="../../intranet-core/www/master">
<property name="title">Companies</property>
<property name="context">context</property>

<br>
<%= [im_user_navbar $letter "/intranet-freelance/index" $next_page_url $previous_page_url [list start_idx order_by how_many view_name user_group_name letter] $menu_select_label] %>

<form method=get action="/intranet-freelance/index">
<%= [export_form_vars user_group_name start_idx order_by how_many view_name letter] %>

<table border=0 cellpadding=1 cellspacing=1>
  <tr>
    <td colspan='2' class=rowtitle align=center>
      Filter Freelancers
    </td>
  </tr>
  <tr>
    <td valign=top>Source Language:</td>
    <td valign=top>
<%= [im_select source_language_id $languages $source_language_id] %>
    </td>
  </tr>
  <tr>
    <td valign=top>Target Language:</td>
    <td valign=top>
<%= [im_select target_language_id $languages $target_language_id] %>
    </td>
  </tr>
  <tr>
    <td valign=top>Recruiting Status:</td>
    <td valign=top>
<%= [im_select rec_status_id $rec_stati $rec_status_id] %>
    </td>
  </tr>
  <tr>
    <td valign=top>Recruiting Test Result:</td>
    <td valign=top>
<%= [im_select rec_test_result_id $rec_test_results $rec_test_result_id] %>
    </td>
  </tr>
  <tr>
    <td></td>
    <td>
      <input type=submit value=Go name=submit>
    </td>
  </tr>
</table>
</form>

<table width=100% cellpadding=2 cellspacing=2 border=0>
  <%= $table_header_html %>
  <%= $table_body_html %>
  <%= $table_continuation_html %>
</table>
