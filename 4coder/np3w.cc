
/*
Np3w's 4coder configuration
*/

#if !defined(FCODER_DEFAULT_BINDINGS)
#define FCODER_DEFAULT_BINDINGS

/*
4coder_default_include.cpp - Default set of commands and setup used in 4coder.

TYPE: 'major-system-include'
*/

// TOP

#if !defined(FCODER_DEFAULT_INCLUDE_CPP)
#define FCODER_DEFAULT_INCLUDE_CPP

#include "4coder_API/custom.h"

#include "4coder_helper/4coder_jump_parsing.h"

// NOTE(allen): Define USE_OLD_STYLE_JUMPS before including to get the old jumps (instead of sticky jumps).
#if !defined(USE_OLD_STYLE_JUMPS)
#define FCODER_JUMP_COMMANDS
#endif

#include "4coder_default_framework.h"
#include "4coder_base_commands.cpp"
#include "4coder_auto_indent.cpp"
#include "4coder_search.cpp"
#include "4coder_jump_parsing.cpp"
#include "4coder_clipboard.cpp"
#include "4coder_system_command.cpp"
#include "4coder_build_commands.cpp"
#include "4coder_project_commands.cpp"
#include "4coder_function_list.cpp"

#if !defined(USE_OLD_STYLE_JUMPS)
#undef FCODER_JUMP_COMMANDS
#include "4coder_sticky_jump.cpp"
#endif

#include "4coder_default_hooks.cpp"

#include "4coder_helper/4coder_bind_helper.h"
#include "4coder_helper/4coder_helper.h"
#include "4coder_helper/4coder_streaming.h"
#include "4coder_helper/4coder_long_seek.h"

#define FSTRING_IMPLEMENTATION
#include "4coder_lib/4coder_string.h"
#include "4coder_lib/4coder_table.h"
#include "4coder_lib/4coder_mem.h"
#include "4coder_lib/4coder_utf8.h"

#include "4cpp/4cpp_lexer.h"

//
// Seeks Using Default Framework Memory
//

static int32_t
buffer_boundary_seek(Application_Links *app, Buffer_Summary *buffer, int32_t start_pos, bool32 seek_forward, Seek_Boundary_Flag flags){
    int32_t result = buffer_boundary_seek(app, buffer, &global_part, start_pos, seek_forward, flags);
    return(result);
}

static void
basic_seek(Application_Links *app, bool32 seek_forward, uint32_t flags){
    View_Summary view = get_active_view(app, AccessProtected);
    Buffer_Summary buffer = get_buffer(app, view.buffer_id, AccessProtected);
    int32_t pos = buffer_boundary_seek(app, &buffer, view.cursor.pos, seek_forward, flags);
    view_set_cursor(app, &view, seek_pos(pos), true);
}

#define right true
#define left false

CUSTOM_COMMAND_SIG(seek_whitespace_right){ basic_seek(app, right, BoundaryWhitespace); }
CUSTOM_COMMAND_SIG(seek_whitespace_left){ basic_seek(app, left, BoundaryWhitespace); }
CUSTOM_COMMAND_SIG(seek_token_right){ basic_seek(app, right, BoundaryToken); }
CUSTOM_COMMAND_SIG(seek_token_left){ basic_seek(app, left, BoundaryToken); }
CUSTOM_COMMAND_SIG(seek_white_or_token_right){basic_seek(app, right, BoundaryToken | BoundaryWhitespace);}
CUSTOM_COMMAND_SIG(seek_white_or_token_left){basic_seek(app, left, BoundaryToken | BoundaryWhitespace);}
CUSTOM_COMMAND_SIG(seek_alphanumeric_right){ basic_seek(app, right, BoundaryAlphanumeric); }
CUSTOM_COMMAND_SIG(seek_alphanumeric_left){ basic_seek(app, left, BoundaryAlphanumeric); }
CUSTOM_COMMAND_SIG(seek_alphanumeric_or_camel_right){ basic_seek(app, right, BoundaryAlphanumeric | BoundaryCamelCase); }
CUSTOM_COMMAND_SIG(seek_alphanumeric_or_camel_left){ basic_seek(app, left, BoundaryAlphanumeric | BoundaryCamelCase); }

#undef right
#undef left

//
// Fast Deletes 
//

CUSTOM_COMMAND_SIG(backspace_word){
    uint32_t access = AccessOpen;
    
    View_Summary view = get_active_view(app, access);
    Buffer_Summary buffer = get_buffer(app, view.buffer_id, access);
    
    if (buffer.exists){
        int32_t pos2 = 0, pos1 = 0;
        
        pos2 = view.cursor.pos;
        exec_command(app, seek_alphanumeric_left);
        refresh_view(app, &view);
        pos1 = view.cursor.pos;
        
        buffer_replace_range(app, &buffer, pos1, pos2, 0, 0);
    }
}

CUSTOM_COMMAND_SIG(delete_word){
    uint32_t access = AccessOpen;
    
    View_Summary view = get_active_view(app, access);
    Buffer_Summary buffer = get_buffer(app, view.buffer_id, access);
    
    if (buffer.exists){
        int32_t pos2 = 0, pos1 = 0;
        
        pos1 = view.cursor.pos;
        exec_command(app, seek_alphanumeric_right);
        refresh_view(app, &view);
        pos2 = view.cursor.pos;
        
        buffer_replace_range(app, &buffer, pos1, pos2, 0, 0);
    }
}

CUSTOM_COMMAND_SIG(snipe_token_or_word){
    uint32_t access = AccessOpen;
    
    View_Summary view = get_active_view(app, access);
    Buffer_Summary buffer = get_buffer(app, view.buffer_id, access);
    
    int32_t pos1 = buffer_boundary_seek(app, &buffer, view.cursor.pos, 0, BoundaryToken | BoundaryWhitespace);
    int32_t pos2 = buffer_boundary_seek(app, &buffer, pos1,            1, BoundaryToken | BoundaryWhitespace);
    
    Range range = make_range(pos1, pos2);
    buffer_replace_range(app, &buffer, range.start, range.end, 0, 0);
}


//
// Line Manipulation
//

CUSTOM_COMMAND_SIG(duplicate_line){
    View_Summary view = get_active_view(app, AccessOpen);
    Buffer_Summary buffer = get_buffer(app, view.buffer_id, AccessOpen);
    
    Partition *part = &global_part;
    
    Temp_Memory temp = begin_temp_memory(part);
    String line_string = {0};
    read_line(app, part, &buffer, view.cursor.line, &line_string);
    
    push_array(part, char, 1);
    ++line_string.memory_size;
    append_s_char(&line_string, '\n');
    
    int32_t pos = buffer_get_line_end(app, &buffer, view.cursor.line) + 1;
    buffer_replace_range(app, &buffer, pos, pos, line_string.str, line_string.size);
    
    end_temp_memory(temp);
}

CUSTOM_COMMAND_SIG(delete_line){
    View_Summary view = get_active_view(app, AccessOpen);
    Buffer_Summary buffer = get_buffer(app, view.buffer_id, AccessOpen);
    
    Partition *part = &global_part;
    
    Temp_Memory temp = begin_temp_memory(part);
    int32_t start = buffer_get_line_start(app, &buffer, view.cursor.line);
    int32_t end = buffer_get_line_end(app, &buffer, view.cursor.line) + 1;
    
    buffer_replace_range(app, &buffer, start, end, 0, 0);
    
    end_temp_memory(temp);
}


//
// Clipboard + Indent Combo Command
//

CUSTOM_COMMAND_SIG(paste_and_indent){
    exec_command(app, paste);
    exec_command(app, auto_tab_range);
}

CUSTOM_COMMAND_SIG(paste_next_and_indent){
    exec_command(app, paste_next);
    exec_command(app, auto_tab_range);
}


//
// Combined Write Commands
//

static void
write_string(Application_Links *app, View_Summary *view, Buffer_Summary *buffer, String string){
    buffer_replace_range(app, buffer, view->cursor.pos, view->cursor.pos, string.str, string.size);
    view_set_cursor(app, view, seek_pos(view->cursor.pos + string.size), 1);
}

static void
write_string(Application_Links *app, String string){
    uint32_t access = AccessOpen;
    View_Summary view = get_active_view(app, access);
    Buffer_Summary buffer = get_buffer(app, view.buffer_id, access);
    write_string(app, &view, &buffer, string);
}

static void
long_braces(Application_Links *app, char *text, int32_t size){
    uint32_t access = AccessOpen;
    View_Summary view = get_active_view(app, access);
    Buffer_Summary buffer = get_buffer(app, view.buffer_id, access);
    int32_t pos = view.cursor.pos;
    
    buffer_replace_range(app, &buffer, pos, pos, text, size);
    view_set_cursor(app, &view, seek_pos(pos + 2), true);
    
    buffer_auto_indent(app, &buffer, pos, pos + size, DEF_TAB_WIDTH, DEFAULT_INDENT_FLAGS | AutoIndent_FullTokens);
    move_past_lead_whitespace(app, &view, &buffer);
}

CUSTOM_COMMAND_SIG(open_long_braces){
    char text[] = "{\n\n}";
    int32_t size = sizeof(text) - 1;
    long_braces(app, text, size);
}

CUSTOM_COMMAND_SIG(open_long_braces_semicolon){
    char text[] = "{\n\n};";
    int32_t size = sizeof(text) - 1;
    long_braces(app, text, size);
}

CUSTOM_COMMAND_SIG(open_long_braces_break){
    char text[] = "{\n\n}break;";
    int32_t size = sizeof(text) - 1;
    long_braces(app, text, size);
}

CUSTOM_COMMAND_SIG(if0_off){
    char text1[] = "\n#if 0";
    int32_t size1 = sizeof(text1) - 1;
    
    char text2[] = "#endif\n";
    int32_t size2 = sizeof(text2) - 1;
    
    View_Summary view = get_active_view(app, AccessOpen);
    Buffer_Summary buffer = get_buffer(app, view.buffer_id, AccessOpen);
    
    Range range = get_range(&view);
    
    if (range.min < range.max){
        Buffer_Edit edits[2];
        char *str = 0;
        char *base = (char*)partition_current(&global_part);
        
        str = push_array(&global_part, char, size1);
        memcpy(str, text1, size1);
        edits[0].str_start = (int32_t)(str - base);
        edits[0].len = size1;
        edits[0].start = range.min;
        edits[0].end = range.min;
        
        str = push_array(&global_part, char, size2);
        memcpy(str, text2, size2);
        edits[1].str_start = (int32_t)(str - base);
        edits[1].len = size2;
        edits[1].start = range.max;
        edits[1].end = range.max;
        
        buffer_batch_edit(app, &buffer, base, global_part.pos, edits, ArrayCount(edits), BatchEdit_Normal);
        
        view = get_view(app, view.view_id, AccessAll);
        if (view.cursor.pos > view.mark.pos){
            view_set_cursor(app, &view, seek_line_char(view.cursor.line+1, view.cursor.character), 1);
        }
        else{
            view_set_mark(app, &view, seek_line_char(view.mark.line+1, view.mark.character));
        }
        
        range = get_range(&view);
        buffer_auto_indent(app, &buffer, range.min, range.max, DEF_TAB_WIDTH, DEFAULT_INDENT_FLAGS | AutoIndent_FullTokens);
        move_past_lead_whitespace(app, &view, &buffer);
    }
}

CUSTOM_COMMAND_SIG(write_todo){
    char space[512];
    String str = make_fixed_width_string(space);
    
    char *name = 0;
    int32_t name_len = 0;
    if (get_current_name(&name, &name_len)){
        append(&str, "// TODO(");
        append(&str, make_string(name, name_len));
        append(&str, "): ");
    }
    else{
        append(&str, "// TODO: ");
    }
    
    write_string(app, str);
}

CUSTOM_COMMAND_SIG(write_note){
    char space[512];
    String str = make_fixed_width_string(space);
    
    char *name = 0;
    int32_t name_len = 0;
    if (get_current_name(&name, &name_len)){
        append(&str, "// NOTE(");
        append(&str, make_string(name, name_len));
        append(&str, "): ");
    }
    else{
        append(&str, "// NOTE: ");
    }
    
    write_string(app, str);
}

CUSTOM_COMMAND_SIG(write_block){
    write_string(app, make_lit_string("/*  */"));
}

CUSTOM_COMMAND_SIG(write_zero_struct){
    write_string(app, make_lit_string(" = {0};"));
}


//
// Open File In Quotes
//

static bool32
file_name_in_quotes(Application_Links *app, String *file_name){
    bool32 result = false;
    uint32_t access = AccessProtected;
    
    View_Summary view = get_active_view(app, access);
    Buffer_Summary buffer = get_buffer(app, view.buffer_id, access);
    
    if (buffer.file_name != 0){
        int32_t pos = view.cursor.pos;
        int32_t start = 0, end = 0;
        buffer_seek_delimiter_forward(app, &buffer, pos, '"', &end);
        buffer_seek_delimiter_backward(app, &buffer, pos, '"', &start);
        ++start;
        
        int32_t size = end - start;
        
        char short_file_name[128];
        // NOTE(allen): This check is necessary because buffer_read_range
        // requiers that the output buffer you provide is at least (end - start) bytes long.
        if (size < sizeof(short_file_name)){
            if (buffer_read_range(app, &buffer, start, end, short_file_name)){
                result = true;
                copy_ss(file_name, make_string(buffer.file_name, buffer.file_name_len));
                remove_last_folder(file_name);
                append_ss(file_name, make_string(short_file_name, size));
            }
        }
    }
    
    return(result);
}

CUSTOM_COMMAND_SIG(open_file_in_quotes){
    char file_name_[256];
    String file_name = make_fixed_width_string(file_name_);
    
    if (file_name_in_quotes(app, &file_name)){
        exec_command(app, change_active_panel);
        View_Summary view = get_active_view(app, AccessAll);
        view_open_file(app, &view, expand_str(file_name), true);
    }
}

CUSTOM_COMMAND_SIG(open_in_other){
    exec_command(app, change_active_panel);
    exec_command(app, interactive_open);
}

CUSTOM_COMMAND_SIG(new_in_other){
    exec_command(app, change_active_panel);
    exec_command(app, interactive_new);
}


//
// File Navigating
//

static bool32
get_cpp_matching_file(Application_Links *app, Buffer_Summary buffer, Buffer_Summary *buffer_out){
    bool32 result = false;
    
    if (buffer.file_name != 0){
        char space[512];
        String file_name = make_string_cap(space, 0, sizeof(space));
        append(&file_name, make_string(buffer.file_name, buffer.file_name_len));
        
        String extension = file_extension(file_name);
        String new_extensions[2] = {0};
        int32_t new_extensions_count = 0;
        
        if (match(extension, "cpp") || match(extension, "cc")){
            new_extensions[0] = make_lit_string("h");
            new_extensions[1] = make_lit_string("hpp");
            new_extensions_count = 2;
        }
        else if (match(extension, "c")){
            new_extensions[0] = make_lit_string("h");
            new_extensions_count = 1;
        }
        else if (match(extension, "h")){
            new_extensions[0] = make_lit_string("c");
            new_extensions[1] = make_lit_string("cpp");
            new_extensions_count = 2;
        }
        else if (match(extension, "hpp")){
            new_extensions[0] = make_lit_string("cpp");
            new_extensions_count = 1;
        }
        
        remove_extension(&file_name);
        int32_t base_pos = file_name.size;
        for (int32_t i = 0; i < new_extensions_count; ++i){
            String ext = new_extensions[i];
            file_name.size = base_pos;
            append(&file_name, ext);
            
            if (open_file(app, buffer_out, file_name.str, file_name.size, false, true)){
                result = true;
                break;
            }
        }
    }
    
    return(result);
}

CUSTOM_COMMAND_SIG(open_matching_file_cpp){
    View_Summary view = get_active_view(app, AccessAll);
    Buffer_Summary buffer = get_buffer(app, view.buffer_id, AccessAll);
    
    Buffer_Summary new_buffer = {0};
    if (get_cpp_matching_file(app, buffer, &new_buffer)){
        get_view_next_looped(app, &view, AccessAll);
        view_set_buffer(app, &view, new_buffer.buffer_id, 0);
        set_active_view(app, &view);
    }
}


//
// Execute Arbitrary Command
//

CUSTOM_COMMAND_SIG(execute_arbitrary_command){
    // NOTE(allen): This isn't a super powerful version of this command, I will expand
    // upon it so that it has all the cmdid_* commands by default.  However, with this
    // as an example you have everything you need to make it work already. You could
    // even use app->memory to create a hash table in the start hook.
    Query_Bar bar;
    char space[1024];
    bar.prompt = make_lit_string("Command: ");
    bar.string = make_fixed_width_string(space);
    
    if (!query_user_string(app, &bar)) return;
    
    // NOTE(allen): Here I chose to end this query bar because when I call another
    // command it might ALSO have query bars and I don't want this one hanging
    // around at that point.  Since the bar exists on my stack the result of the query
    // is still available in bar.string though.
    end_query_bar(app, &bar, 0);
    
    if (match_ss(bar.string, make_lit_string("load project"))){
        exec_command(app, load_project);
    }
    else if (match_ss(bar.string, make_lit_string("open all code"))){
        exec_command(app, open_all_code);
    }
    else if (match_ss(bar.string, make_lit_string("open all code recursive"))){
        exec_command(app, open_all_code_recursive);
    }
    else if(match_ss(bar.string, make_lit_string("close all code"))){
        exec_command(app, close_all_code);
    }
    else if (match_ss(bar.string, make_lit_string("dos lines")) ||
             match_ss(bar.string, make_lit_string("dosify"))){
        exec_command(app, eol_dosify);
    }
    else if (match_ss(bar.string, make_lit_string("nix lines")) ||
             match_ss(bar.string, make_lit_string("nixify"))){
        exec_command(app, eol_nixify);
    }
    else{
        print_message(app, literal("unrecognized command\n"));
    }
}

#endif

// BOTTOM

void
default_keys(Bind_Helper *context){
    begin_map(context, mapid_global);
    
    bind(context, 'p', MDFR_CTRL, open_panel_vsplit);
    bind(context, '_', MDFR_CTRL, open_panel_hsplit);
    bind(context, 'P', MDFR_CTRL, close_panel);
    bind(context, ',', MDFR_CTRL, change_active_panel);
    bind(context, '<', MDFR_CTRL, change_active_panel_backwards);
    
    bind(context, 'n', MDFR_CTRL, interactive_new);
    bind(context, 'o', MDFR_CTRL, interactive_open_or_new);
    bind(context, 'o', MDFR_ALT, open_in_other);
    bind(context, 'k', MDFR_CTRL, interactive_kill_buffer);
    bind(context, 'i', MDFR_CTRL, interactive_switch_buffer);
    bind(context, 'w', MDFR_CTRL, save_as);
    bind(context, 'h', MDFR_CTRL, project_go_to_root_directory);
    
    bind(context, 'c', MDFR_ALT, open_color_tweaker);
    bind(context, 'd', MDFR_ALT, open_debug);
    
    bind(context, '.', MDFR_ALT, change_to_build_panel);
    bind(context, ',', MDFR_ALT, close_build_panel);
    bind(context, 'n', MDFR_ALT, goto_next_error);
    bind(context, 'N', MDFR_ALT, goto_prev_error);
    bind(context, 'M', MDFR_ALT, goto_first_error);
    bind(context, 'm', MDFR_ALT, build_in_build_panel);
    
    bind(context, 'z', MDFR_ALT, execute_any_cli);
    bind(context, 'Z', MDFR_ALT, execute_previous_cli);
    
    bind(context, 'x', MDFR_ALT, execute_arbitrary_command);
    
    bind(context, 's', MDFR_ALT, show_scrollbar);
    bind(context, 'w', MDFR_ALT, hide_scrollbar);
    bind(context, 'b', MDFR_ALT, toggle_filebar);
    
    bind(context, '@', MDFR_ALT, toggle_mouse);
    bind(context, key_page_up, MDFR_CTRL, toggle_fullscreen);
    bind(context, 'E', MDFR_ALT, exit_4coder);
    
    bind(context, key_f1, MDFR_NONE, project_fkey_command);
    bind(context, key_f2, MDFR_NONE, project_fkey_command);
    bind(context, key_f3, MDFR_NONE, project_fkey_command);
    bind(context, key_f4, MDFR_NONE, project_fkey_command);
    
    bind(context, key_f5, MDFR_NONE, project_fkey_command);
    bind(context, key_f6, MDFR_NONE, project_fkey_command);
    bind(context, key_f7, MDFR_NONE, project_fkey_command);
    bind(context, key_f8, MDFR_NONE, project_fkey_command);
    
    bind(context, key_f9, MDFR_NONE, project_fkey_command);
    bind(context, key_f10, MDFR_NONE, project_fkey_command);
    bind(context, key_f11, MDFR_NONE, project_fkey_command);
    bind(context, key_f12, MDFR_NONE, project_fkey_command);
    
    bind(context, key_f13, MDFR_NONE, project_fkey_command);
    bind(context, key_f14, MDFR_NONE, project_fkey_command);
    bind(context, key_f15, MDFR_NONE, project_fkey_command);
    bind(context, key_f16, MDFR_NONE, project_fkey_command);
    
    end_map(context);
    
    begin_map(context, default_code_map);
    
    // NOTE(allen|a3.1): Set this map (default_code_map == mapid_user_custom) to
    // inherit from mapid_file.  When searching if a key is bound
    // in this map, if it is not found here it will then search mapid_file.
    //
    // If this is not set, it defaults to mapid_global.
    inherit_map(context, mapid_file);
    
    // NOTE(allen|a3.1): Children can override parent's bindings.
    bind(context, key_right, MDFR_CTRL, seek_alphanumeric_or_camel_right);
    bind(context, key_left, MDFR_CTRL, seek_alphanumeric_or_camel_left);
    
    // NOTE(allen|a3.2): Specific keys can override vanilla keys,
    // and write character writes whichever character corresponds
    // to the key that triggered the command.
    bind(context, '\n', MDFR_NONE, write_and_auto_tab);
    bind(context, '\n', MDFR_SHIFT, write_and_auto_tab);
    bind(context, '}', MDFR_NONE, write_and_auto_tab);
    bind(context, ')', MDFR_NONE, write_and_auto_tab);
    bind(context, ']', MDFR_NONE, write_and_auto_tab);
    bind(context, ';', MDFR_NONE, write_and_auto_tab);
    bind(context, '#', MDFR_NONE, write_and_auto_tab);
    
    bind(context, '\t', MDFR_NONE, word_complete);
    bind(context, '\t', MDFR_CTRL, auto_tab_range);
    bind(context, '\t', MDFR_SHIFT, auto_tab_line_at_cursor);
    
    bind(context, 't', MDFR_ALT, write_todo);
    bind(context, 'y', MDFR_ALT, write_note);
    bind(context, 'r', MDFR_ALT, write_block);
    bind(context, '[', MDFR_CTRL, open_long_braces);
    bind(context, '{', MDFR_CTRL, open_long_braces_semicolon);
    bind(context, '}', MDFR_CTRL, open_long_braces_break);
    bind(context, 'i', MDFR_ALT, if0_off);
    bind(context, '1', MDFR_ALT, open_file_in_quotes);
    bind(context, '2', MDFR_ALT, open_matching_file_cpp);
    bind(context, '0', MDFR_CTRL, write_zero_struct);
    bind(context, 'I', MDFR_CTRL, list_all_functions_current_buffer);
    
    end_map(context);
    
    
    begin_map(context, mapid_file);
    
    // NOTE(allen|a3.4.4): Binding this essentially binds
    // all key combos that would normally insert a character
    // into a buffer. If the code for the key is not an enum
    // value such as key_left or key_back then it is a vanilla key.
    // It is possible to override this binding for individual keys.
    bind_vanilla_keys(context, write_character);
    
    // NOTE(allen|a4.0.7): You can now bind left and right clicks.
    // They only trigger on mouse presses.  Modifiers do work
    // so control+click shift+click etc can now have special meanings.
    bind(context, key_mouse_left, MDFR_NONE, click_set_cursor);
    bind(context, key_mouse_right, MDFR_NONE, click_set_mark);
    
    // NOTE(allen|a4.0.11): You can now bind left and right mouse
    // button releases.  Modifiers do work so control+release shift+release
    // etc can now have special meanings.
    bind(context, key_mouse_left_release, MDFR_NONE, click_set_mark);
    
    bind(context, key_left, MDFR_NONE, move_left);
    bind(context, key_right, MDFR_NONE, move_right);
    bind(context, key_del, MDFR_NONE, delete_char);
    bind(context, key_del, MDFR_SHIFT, delete_char);
    bind(context, key_back, MDFR_NONE, backspace_char);
    bind(context, key_back, MDFR_SHIFT, backspace_char);
    bind(context, key_up, MDFR_NONE, move_up);
    bind(context, key_down, MDFR_NONE, move_down);
    bind(context, key_end, MDFR_NONE, seek_end_of_line);
    bind(context, key_home, MDFR_NONE, seek_beginning_of_line);
    bind(context, key_page_up, MDFR_NONE, page_up);
    bind(context, key_page_down, MDFR_NONE, page_down);
    
    bind(context, key_right, MDFR_CTRL, seek_whitespace_right);
    bind(context, key_left, MDFR_CTRL, seek_whitespace_left);
    bind(context, key_up, MDFR_CTRL, seek_whitespace_up_end_line);
    bind(context, key_down, MDFR_CTRL, seek_whitespace_down_end_line);
    
    bind(context, key_up, MDFR_ALT, move_up_10);
    bind(context, key_down, MDFR_ALT, move_down_10);
    
    bind(context, key_back, MDFR_CTRL, backspace_word);
    bind(context, key_del, MDFR_CTRL, delete_word);
    bind(context, key_back, MDFR_ALT, snipe_token_or_word);
    
    bind(context, ' ', MDFR_CTRL, set_mark);
    bind(context, 'a', MDFR_CTRL, replace_in_range);
    bind(context, 'c', MDFR_CTRL, copy);
    bind(context, 'd', MDFR_CTRL, delete_range);
    bind(context, 'e', MDFR_CTRL, center_view);
    bind(context, 'E', MDFR_CTRL, left_adjust_view);
    bind(context, 'f', MDFR_CTRL, search);
    bind(context, 'F', MDFR_CTRL, list_all_locations);
    bind(context, 'F', MDFR_ALT, list_all_substring_locations_case_insensitive);
    bind(context, 'g', MDFR_CTRL, goto_line);
    bind(context, 'j', MDFR_CTRL, to_lowercase);
    bind(context, 'K', MDFR_CTRL, kill_buffer);
    bind(context, 'l', MDFR_CTRL, toggle_line_wrap);
    bind(context, 'm', MDFR_CTRL, cursor_mark_swap);
    bind(context, 'O', MDFR_CTRL, reopen);
    bind(context, 'q', MDFR_CTRL, query_replace);
    bind(context, 'Q', MDFR_CTRL, query_replace_identifier);
    bind(context, 'r', MDFR_CTRL, reverse_search);
    bind(context, 's', MDFR_CTRL, save);
    bind(context, 't', MDFR_CTRL, search_identifier);
    bind(context, 'T', MDFR_CTRL, list_all_locations_of_identifier);
    bind(context, 'u', MDFR_CTRL, to_uppercase);
    bind(context, 'v', MDFR_CTRL, paste_and_indent);
    bind(context, 'v', MDFR_ALT, toggle_virtual_whitespace);
    bind(context, 'V', MDFR_CTRL, paste_next_and_indent);
    bind(context, 'x', MDFR_CTRL, cut);
    bind(context, 'y', MDFR_CTRL, redo);
    bind(context, 'z', MDFR_CTRL, undo);
    
    bind(context, '2', MDFR_CTRL, decrease_line_wrap);
    bind(context, '3', MDFR_CTRL, increase_line_wrap);
    
    bind(context, '?', MDFR_CTRL, toggle_show_whitespace);
    bind(context, '~', MDFR_CTRL, clean_all_lines);
    bind(context, '\n', MDFR_NONE, newline_or_goto_position);
    bind(context, '\n', MDFR_SHIFT, newline_or_goto_position_same_panel);
    bind(context, ' ', MDFR_SHIFT, write_character);
    
    end_map(context);
}

#ifndef NO_BINDING
extern "C" int32_t
get_bindings(void *data, int32_t size){
    Bind_Helper context_ = begin_bind_helper(data, size);
    Bind_Helper *context = &context_;
    
    set_all_default_hooks(context);
    default_keys(context);
    
    int32_t result = end_bind_helper(context);
    return(result);
}
#endif //NO_BINDING

#endif //FCODER_DEFAULT_BINDINGS

// BOTTOM



