# /www/intranet/users/freelance-info-update.tcl
#

ad_page_contract {
    @param user_id
    @author Guillermo Belcic
    @creation-date 10-13-2003
    @cvs-id freelance-info-update.tcl,v 3.2.6.3.2.4 2000/09/22 01:36:17 kevin Exp
} {
    user_id:integer,notnull
}

# ---------------------------------------------------------------
# Security
# ---------------------------------------------------------------

# Also accept "user_id_from_search" instead of user_id (the one to edit...)
if [info exists user_id_from_search] { set user_id $user_id_from_search}
set current_user_id [ad_maybe_redirect_for_registration]

set myself_p 0
if { $user_id == $current_user_id } { set myself_p 1} 

set current_user_is_admin_p [im_is_user_site_wide_or_intranet_admin $current_user_id]
set current_user_is_wheel_p [ad_user_group_member [im_wheel_group_id] $current_user_id]
set current_user_is_employee_p [im_user_is_employee_p $current_user_id]
set current_user_admin_p [|| $current_user_is_admin_p $current_user_is_wheel_p]

set user_is_customer_p [ad_user_group_member [im_customer_group_id] $user_id]
set user_is_freelance_p [ad_user_group_member [im_freelance_group_id] $user_id]
set user_is_admin_p [im_is_user_site_wide_or_intranet_admin $user_id]
set user_is_wheel_p [ad_user_group_member [im_wheel_group_id] $user_id]
set user_is_employee_p [im_user_is_employee_p $user_id]

# Determine the type of the user to view:
set user_type "none"
if {$user_is_freelance_p} { set user_type "freelance" }
if {$user_is_employee_p} { set user_type "employee" }
if {$user_is_customer_p} { set user_type "customer" }
if {$user_is_wheel_p} { set user_type "wheel" }
if {$user_is_admin_p} { set user_type "admin" }

# Check if "user" belongs to a group that is administered by 
# the current users
set administrated_user_ids [db_list administated_user_ids "
select distinct
	m2.user_id
from
	user_group_map m,
	user_group_map m2
where
	m.user_id=:current_user_id
	and m.role='administrator'
	and m.group_id=m2.group_id
"]

set user_in_administered_project 0
if {[lsearch -exact $administrated_user_ids $user_id] > -1} { 
    set user_in_administered_project 1
}

# -------------- Permission Matrix ----------------

# permission_matrix = [$view_user $edit_user]
set permission_matrix [im_user_permission_matrix $current_user_id $user_id $user_type $current_user_admin_p $user_in_administered_project]
set view_user [lindex $permission_matrix 0]
set edit_user [lindex $permission_matrix 1]
set show_admin_links $current_user_admin_p


# Create an error if the current_user isn't allowed to see the user
if {!$edit_user} {
    ad_return_complaint "Insufficient Privileges" "
    <li>You have insufficient privileges to view this user."
    return
}


# ---------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------

set todays_date [lindex [split [ns_localsqltimestamp] " "] 0]
set bgcolor(0) "class=roweven"
set bgcolor(1) "class=rowodd"

set return_url [im_url_with_query]

#if {[string equal "" $return_url]} {
#    set return_url "/intranet/users/view?user_id=$user_id"
#}

# ---------------------------------------------------------------
# Get everything about the freelance
# ---------------------------------------------------------------

db_0or1row freelancers_info {
select
    u.first_names||' '||u.last_name as user_name,
    f.*
from 
    users u,
    im_freelancers f
where
    u.user_id = :user_id
    and u.user_id = f.user_id(+)
}

# --------------- Set page design as a function of the freelance data-----

if { [empty_string_p $user_name]} {
    ad_return_complaint 1 "<li>We couldn't find user \#$user_id; perhaps this person was nuke?"
    return
}

set page_title "$user_name"
if {$user_is_employee_p} {
    set context_bar [ad_context_bar_ws [list /intranet/users/ "Users"] $page_title]
} else {
    set context_bar [ad_context_bar_ws $page_title]
}

# ---------------------------------------------------------------
# Making body table
# ---------------------------------------------------------------

set rates_html "
<form action=freelance-info-update-2 method=POST>
[export_form_vars user_id]
<table cellpadding=0 cellspacing=2 border=0>
<tr><td colspan=2 class=rowtitle align=center>Rates Information</td></tr>
<tr><td>Web Site</td><td><input type=text name=web_site [export_form_value web_site]></td></tr>
<tr><td>Translation rate</td><td><input type=text name=translation_rate [export_form_value translation_rate]></td></tr>
<tr><td>Editing rate</td><td><input type=text name=editing_rate [export_form_value editing_rate]></td></tr>
<tr><td>Hourly rate</td><td><input type=text name=hourly_rate [export_form_value hourly_rate]></td></tr>
<tr><td>Bank Account</td><td><input type=text name=bank_account [export_form_value bank_account]></td></tr>
<tr><td>Bank</td><td><input type=text name=bank [export_form_value bank]></td></tr>
<tr><td>Payment Method</td><td>[im_category_select "Intranet Payment Type" "payment_method" "$payment_method_id"]</td></tr>
<tr><td>Note</td><td><textarea type=text cols=50 rows=5 name=note>$note</textarea></td></tr>
"

# don't show the "private_note" field to the user himself.
# Freelancers and other unprivileged users won't be able to see the 
# user anyway
if { !$myself_p } {
    append rates_html "<tr><td>Private Notes</td><td><textarea type=text cols=50 rows=5 name=private_note>$private_note</textarea></td></tr>"
}

append rates_html "
<tr><td>CV</td><td><input type=text name=cv [export_form_value cv]></td></tr>
</table>
<center>
<input type=submit name=submit value=Submit>
</center>
</form>
"
set page_body "
$rates_html
"
doc_return  200 text/html [im_return_template]
