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
# Default & Security
# ---------------------------------------------------------------

# Also accept "user_id_from_search" instead of user_id (the one to edit...)
if [info exists user_id_from_search] { set user_id $user_id_from_search}
set todays_date [lindex [split [ns_localsqltimestamp] " "] 0]
set bgcolor(0) "class=roweven"
set bgcolor(1) "class=rowodd"
set return_url [im_url_with_query]
set current_user_id [ad_maybe_redirect_for_registration]

im_user_permissions $current_user_id $user_id view read write admin
if {!$admin} {
    ad_return_complaint 1 "<li>You have insufficient permissions to pursue this operation"
    return
}

# ---------------------------------------------------------------
# Get everything about the freelance
# ---------------------------------------------------------------

db_0or1row freelancers_info {
select
    pe.first_names||' '||pe.last_name as user_name,
    f.*
from 
    persons pe,
    im_freelancers f
where
    pe.person_id = :user_id
    and pe.person_id = f.user_id(+)
}

# --------------- Set page design as a function of the freelance data-----

if { [empty_string_p $user_name]} {
    ad_return_complaint 1 "<li>We couldn't find user \#$user_id; perhaps this person was nuke?"
    return
}

set page_title "$user_name"
set context_bar [ad_context_bar_ws [list /intranet/users/ "Users"] $page_title]

# ---------------------------------------------------------------
# Making body table
# ---------------------------------------------------------------

set rates_html "
<form action=freelance-info-update-2 method=POST>
[export_form_vars user_id]
<table cellpadding=0 cellspacing=2 border=0>
<tr><td colspan=2 class=rowtitle align=center>Rates Information</td></tr>
<tr><td>Web Site</td><td><input type=text name=web_site value=$web_site></td></tr>
<tr><td>Translation rate</td><td><input type=text name=translation_rate value=$translation_rate></td></tr>
<tr><td>Editing rate</td><td><input type=text name=editing_rate value=$editing_rate></td></tr>
<tr><td>Hourly rate</td><td><input type=text name=hourly_rate value=$hourly_rate></td></tr>
<tr><td>Bank Account</td><td><input type=text name=bank_account value=$bank_account></td></tr>
<tr><td>Bank</td><td><input type=text name=bank value=$bank></td></tr>
<tr><td>Payment Method</td><td>[im_category_select "Intranet Payment Type" "payment_method" "$payment_method_id"]</td></tr>
<tr><td>Note</td><td><textarea type=text cols=50 rows=5 name=note>$note</textarea></td></tr>
"

# don't show the "private_note" field to the user himself.
# Freelancers and other unprivileged users won't be able to see the 
# user anyway

if { $admin } {
    append rates_html "<tr><td>Private Notes</td><td><textarea type=text cols=50 rows=5 name=private_note>$private_note</textarea></td></tr>"
}

append rates_html "
<tr><td>CV</td><td><input type=text name=cv value=$cv></td></tr>
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
