ad_page_contract {
    Show an Skill - Object (Sub-) Type table.
    This table allows admins to determine where DynField skills
    should appear, depending on the object's ]po[-type_id
    (as opposed to the OpenACS type)

    @author Malte Sussdorff (malte.sussdorff@cognovis.de)
    @cvs-id $Id$
} {
    object_type
}

# --------------------------------------------------------------

set page_title "Skill-Type-Map"
set context [list [list "index" "Freelance"] $page_title]

set bgcolor(0) " class=roweven "
set bgcolor(1) " class=rowodd "

set user_id [ad_maybe_redirect_for_registration]
set user_is_admin_p [im_is_user_site_wide_or_intranet_admin $user_id]
if {!$user_is_admin_p} {
    ad_return_complaint 1 "You have insufficient privileges to use this page"
    return
}

set return_url [im_url_with_query]
set acs_object_type $object_type

# --------------------------------------------------------------
# Horizontal Dimension - Just the list of ObjectTypes
# The mapping between object types and categories is
# not dealt with in acs_object_types, so hard-code here
# while we haven't integrated this into the Metadata model.
# ToDo: Integrate type and status into metadata model.

set category_type [im_dynfield::type_category_for_object_type -object_type $acs_object_type]
if {"" == $category_type} { 
    ad_return_complaint 1 "
	No 'Type Category Type' defined for type '$object_type'<br>
	The field 'acs_object_types.type_category_type' is empty for object type '$object_type'.<br>
	This probably means that the SQL creation or upgrade scripts have not run for this object type.
    "
}


set object_subtype_sql ""

# The "dimension" is a list of values to be displayed on top.
set top_scale [db_list top_dim "
	select	category_id
	from	im_categories
	where	category_type = :category_type and
		(enabled_p is null or enabled_p = 't')
		$object_subtype_sql
	order by
		category_id
"]


# Exception for timesheet tasks: Include the project_type_id=100 (Task)
# ToDo: Remove once tasks have their own task_type_id.
if {"im_timesheet_task" == $object_type} {
    lappend top_scale 100
    append object_subtype_sql "OR category_id = 100"
}


# The array maps category_id into "category" - a pretty 
# string for each column, to be used as column header
set max_length 8
db_foreach top_scale_map "
	select	category_id,
		category
	from	im_categories
	where	category_type = :category_type
		$object_subtype_sql
	order by
		category_id
" { 
    set col_title ""
    foreach c $category {
        if {[string length $c] == [expr $max_length+1]} { 
	        append col_title $c
            set c ""
	    }
	    while {[string length $c] > $max_length} {
	        append col_title "[string range $c 0 [expr $max_length-1]] "
	        set c [string range $c $max_length end]
	    }
        append col_title " $c "
    }
    set top_scale_map($category_id) $col_title
}


# --------------------------------------------------------------
# Vertical Dimension - The list of Skills
# The "dimension" is a list of values to be displayed on left.


# The array maps category_id into "skill_id category" - a pretty
# string for each column, to be used as column header
db_foreach left_scale_map "select category_id as skill_type_id from im_categories where category_type = 'Intranet Skill Type'" { 
    set left_scale_map($skill_type_id) [im_category_from_id $skill_type_id] 
}

# --------------------------------------------------------------
# Get the information about the map and stuff it into a hash array
# for convenient matrix display.
set sql "
	select  skill_type_id,
	        object_type_id,
	        display_mode,
            category
	from    im_freelance_skill_type_map, im_categories
	where
            category_type = :category_type
            and category_id = object_type_id
	order by
		category
"

    
db_foreach skill_table_map $sql {
    set key "$skill_type_id.$object_type_id"
    set hash($key) $display_mode
}



# --------------------------------------------------------------
# Display the table

set header "<td></td>\n"
foreach top $top_scale {
    set top_pretty $top_scale_map($top)
    append header "
	<td class=rowtitle>
	$top_pretty
	</td>
    "
}
set header_html "<tr class=rowtitle valign=top>\n$header</tr>\n"

set body_html ""
set ctr 0

set skill_category_ids [db_list skill_categories "select category_id from im_categories where category_type = 'Intranet Skill Type'"]
foreach skill_type_id $skill_category_ids {
    append body_html "<tr $bgcolor([expr $ctr % 2])>\n"
    append body_html "<td>$left_scale_map($skill_type_id)</td>\n"

    foreach top $top_scale {
	set object_type_id $top
	set key "$skill_type_id.$object_type_id"
	set mode "none"
	if {[info exists hash($key)]} { set mode $hash($key) }
	ns_log Notice "skill-type-map: hash($key) => $mode"

	set none_checked ""
	set disp_checked ""
	set edit_checked ""
	switch $mode {
	    none { set none_checked "checked" }
	    display { set disp_checked "checked" }
	    edit { set edit_checked "checked" }
	}

	set val "
<nobr>
<font size=-2>
<input value=none type=radio name=\"attrib.$skill_type_id.$object_type_id\" $none_checked>
<input value=display type=radio name=\"attrib.$skill_type_id.$object_type_id\" $disp_checked>
<input value=edit type=radio name=\"attrib.$skill_type_id.$object_type_id\" $edit_checked>
</font>
</nobr>
"

	append body_html "<td>$val</td>\n"
    }
    append body_html "</tr>\n"
    incr ctr
}





# ------------------------------------------------------------------
# Left Navigation Bar
# ------------------------------------------------------------------

set left_navbar_html "
            <div class=\"filter-block\">
                <div class=\"filter-title\">
                    [lang::message::lookup "" intranet-dynfield.DynField_Admin "DynField Admin"]
                </div>
		[im_dynfield::left_navbar]
            </div>
            <hr/>
"
