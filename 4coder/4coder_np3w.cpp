/*
 4coder_np3w - Np3w's 4coder configuration
 
TYPE: 'build-target'
*/

// TOP

#if !defined(FCODER_DEFAULT_BINDINGS)
#define FCODER_DEFAULT_BINDINGS

#include "4coder_default_include.cpp"


/* BEGIN BOOKMARKS CODE */

#include <stdarg.h>

static uint32_t npStringMatchScore(char *a, uint32_t a_len, char *b, uint32_t b_len){
    uint32_t score = 0;
    
    char *a_iter = a;
    char *a_end = a + a_len;
    
    char *b_iter = b;
    char *b_end = b + b_len;
    
    while(a_iter < a_end && b_iter < b_end){
        if(*a_iter == *b_iter){
            score += 1;
            
            a_iter += 1;
            b_iter += 1;
        }else{
            b_iter += 1;
        }
    }
    return score;
}

static void npPrint(Application_Links *app, const char *format, ...){
    char buffer[5000];
    va_list list;
    va_start(list, format);
    
    vsnprintf(buffer, sizeof(buffer), format, list);
    
    va_end(list);
    
    print_message(app, buffer, strlen(buffer));
    
    print_message(app, "\n", 1);
}

struct NpBookmark{
    bool active;
    
#if 0
    int32_t line;
    char bufName[512];
#else
    Marker_Handle marker; // @todo Marker lifetimes?
#endif
    
    char bookmarkName[512];
};

NpBookmark npBookmarks[256];

#define npArrayLength(_array_) (sizeof(_array_) / sizeof((_array_)[0]))
#define npForRange(_i_, _count_) for(int _i_ = 0; _i_ < (_count_); _i_ += 1)

static void npSetBookmark(Application_Links *app, Buffer_Summary *buffer, int32_t pos, int32_t line){
    npPrint(app, "Setting bookmark at %.*s:%d", buffer->buffer_name_len, buffer->buffer_name, line);
    
    bool found = false;
    npForRange(i, npArrayLength(npBookmarks)){
        if(!npBookmarks[i].active){
            found = true;
            
            npBookmarks[i].active = true;
            
            npBookmarks[i].marker = buffer_add_markers(app, buffer, /*markerCount=*/1);
            Marker srcMarker = { pos, /*lean right*/false };
            buffer_set_markers(app, buffer, npBookmarks[i].marker, /*index, count*/0, 1, &srcMarker);
            
            snprintf(npBookmarks[i].bookmarkName, sizeof(npBookmarks[i].bookmarkName), "%.*s:%d", buffer->buffer_name_len, buffer->buffer_name, line);
            break;
        }
    }
    if(!found){
        npPrint(app, "**** npBookmarks: ERROR: Ran out of space for more bookmarks");
    }
}

CUSTOM_COMMAND_SIG(np_set_bookmark_at_cursor){
    View_Summary view = get_active_view(app, AccessOpen);
    Buffer_Summary buffer = get_buffer(app, view.buffer_id, AccessOpen);
    npSetBookmark(app, &buffer, view.cursor.pos, view.cursor.line);
}

struct npSearchBookmarkItem{
    NpBookmark *bookmark;
    uint32_t score;
};

static int npCompareSearchItems(const void *_a, const void *_b){
    npSearchBookmarkItem *a = (npSearchBookmarkItem*)_a;
    npSearchBookmarkItem *b = (npSearchBookmarkItem*)_b;
    
    if(a->score < b->score){
        return 1;
    }else if(a->score > b->score){
        return -1;
    }else{
        return 0;
    }
}

static void npSearchBookmarks(Application_Links *app, NpBookmark **results, int resultCount, String search){
    npSearchBookmarkItem items[npArrayLength(npBookmarks)] = {};
    
    npForRange(i, npArrayLength(npBookmarks)){
        items[i].bookmark = (npBookmarks[i].active) ? (&npBookmarks[i]) : (nullptr);
        
        if(items[i].bookmark){
            // Calculate the score
            items[i].score = npStringMatchScore(search.str, search.size, items[i].bookmark->bookmarkName, strlen(items[i].bookmark->bookmarkName));
            
            npPrint(app, "npSearchBookmarks:   %s -> %d", items[i].bookmark->bookmarkName, items[i].score);
        }
    }
    
    qsort(items, npArrayLength(items), sizeof(items[0]), npCompareSearchItems);
    
    npForRange(i, resultCount){
        results[i] = (i < npArrayLength(items)) ? (items[i].bookmark) : (nullptr);
    }
}

CUSTOM_COMMAND_SIG(np_interactive_goto_bookmark){
    Query_Bar results[7];
    char resultTexts[7][256];
    
    npForRange(i, npArrayLength(results)){
        results[i].prompt = make_lit_string(": ");
        results[i].string = make_fixed_width_string(resultTexts[i]);
        
        start_query_bar(app, &results[i], 0);
    }
    
    Query_Bar bar;
    char stringBuffer[256];
    bar.prompt = make_lit_string("");
    bar.string = make_fixed_width_string(stringBuffer);
    
    if(start_query_bar(app, &bar, 0)){
        while(1){
            NpBookmark *searchResults[npArrayLength(results)];
            npSearchBookmarks(app, searchResults, npArrayLength(searchResults), bar.string);
            npForRange(i, npArrayLength(results)){
                int resultIndex = npArrayLength(results) - 1 - i;
                NpBookmark *bm = searchResults[i];
                
                resultTexts[resultIndex][0] = '\0';
                
                if(bm){
                    Buffer_Summary buffer = get_buffer_by_marker_handle(app, bm->marker, AccessOpen);
                    
                    Marker marker;
                    if(buffer_get_markers(app, &buffer, bm->marker, /*index, count, out=*/0, 1, &marker)){
                        
                        Buffer_Seek seek = {};
                        seek.type = buffer_seek_pos;
                        seek.pos = marker.pos;
                        
                        Partial_Cursor cursor = {};
                        buffer_compute_cursor(app, &buffer, seek, &cursor);
                        
                        int32_t start = buffer_get_line_start(app, &buffer, cursor.line);
                        int32_t end = buffer_get_line_end(app, &buffer, cursor.line);
                        
                        char content[256];
                        
                        if(end - start > sizeof(content)){
                            end = start + sizeof(content);
                        }
                        
                        buffer_read_range(app, &buffer, start, end, content);
                        
                        size_t len = snprintf(results[resultIndex].string.str, results[resultIndex].string.memory_size, "%s  /: %.*s", bm->bookmarkName, end - start, content);
                        
                        if(len < results[resultIndex].string.memory_size){
                            results[resultIndex].string.size = len;
                        }else{
                            results[resultIndex].string.size = results[resultIndex].string.memory_size;
                        }
                    }
                }
            }
            
            User_Input in = get_user_input(app, EventOnAnyKey, EventOnEsc | EventOnButton);
            
            if(in.abort){
                break;
            }
            
            uint8_t character[4];
            uint32_t length = 0;
            if(key_is_unmodified(&in.key)){
                length = to_writable_character(in, character);
            }
            
            if(in.type == UserInputKey){
                if(in.key.keycode == '\n' || in.key.keycode == '\t'){
                    NpBookmark *jmpTo = searchResults[0];
                    if(jmpTo){
                        View_Summary view = get_active_view(app, AccessOpen);
                        
                        Buffer_Summary buffer = get_buffer_by_marker_handle(app, jmpTo->marker, AccessOpen); // @todo What happens here when the buffer has been killed? Will the marker point into bad memory?
                        if(buffer.exists){
                            Marker marker;
                            if(buffer_get_markers(app, &buffer, jmpTo->marker, /*index, count, out=*/0, 1, &marker)){
                                Buffer_Seek seek = {};
                                seek.type = buffer_seek_pos;
                                seek.pos = marker.pos;
                                
                                view_set_buffer(app, &view, buffer.buffer_id, /*flags=*/0);
                                view_set_cursor(app, &view, seek, true);
                            }
                        }
                    }
                    break;
                }else if(in.key.keycode == key_back){
                    backspace_utf8(&bar.string);
                }else if(length > 0){
                    append_ss(&bar.string, make_string(character, length));
                }
            }
        }
        
        end_query_bar(app, &bar, 0);
    }
    
    npForRange(i, npArrayLength(results)){
        end_query_bar(app, &results[i], 0);
    }
}

/* END BOOKMARKS CODE */




/* BEGIN CODE BASED ON https://4coder.handmade.network/forums/t/2421-%5Bsolved%5D_need_help_implementing_shift_based_selection */

bool cro_selection_active = false;
CUSTOM_COMMAND_SIG(cro_selection_abort) {
    View_Summary view = get_active_view(app, AccessProtected);
    view_set_highlight(app, &view, 0, 0, false);
    cro_selection_active = false;
}
void cro_selection_cont(Application_Links* app, Custom_Command_Function wrapped_func) {
    bool was_active = cro_selection_active;
    if (!cro_selection_active) {
        cro_selection_active = true;
        set_mark(app);
    }
    wrapped_func(app);
    View_Summary view = get_active_view(app, AccessProtected);
    Range range = get_range(&view);
    int32_t pos = view.cursor.character_pos;
    view_set_highlight(app, &view, range.min, range.max, true);
    view_set_cursor(app, &view, seek_character_pos(pos), 1);
    
    // NOTE(Np3w): I don't use it to select large vertical pieces of code so I don't care
    //center_view(app); /// because for some reason when you select move down the buffer doesn't scroll with your...
    
}
void cro_selection_delete_or_cmd(Application_Links* app, Custom_Command_Function wrapped_func) {
    if (cro_selection_active) {
        View_Summary view = get_active_view(app, AccessProtected);
        Range range = get_range(&view);
        Buffer_Summary buffer = get_buffer(app, view.buffer_id, AccessOpen);
        buffer_replace_range(app, &buffer, range.min, range.max, 0, 0);
        cro_selection_abort(app);
    } else {
        if (wrapped_func) wrapped_func(app);
    }
}
CUSTOM_COMMAND_SIG(cro_selection_write_character){
    uint32_t access = AccessOpen;
    View_Summary view = get_active_view(app, access);
    
    User_Input in = get_command_input(app);
    
    uint8_t character[4];
    uint32_t length = to_writable_character(in, character);
    if (length != 0){
        Buffer_Summary buffer = get_buffer(app, view.buffer_id, access);
        int32_t pos = view.cursor.pos;
        
        Marker next_cursor_marker = {0};
        next_cursor_marker.pos = character_pos_to_pos(app, &view, &buffer, view.cursor.character_pos);
        next_cursor_marker.lean_right = true;
        
        Marker_Handle handle = buffer_add_markers(app, &buffer, 1);
        buffer_set_markers(app, &buffer, handle, 0, 1, &next_cursor_marker);
        
        if(cro_selection_active) {
            Range range = get_range(&view);
            buffer_replace_range(app, &buffer, range.min, range.max,  (char*)character, length);
            cro_selection_abort(app);
        } else {
            buffer_replace_range(app, &buffer, pos, pos, (char*)character, length);
        }
        
        buffer_get_markers(app, &buffer, handle, 0, 1, &next_cursor_marker);
        buffer_remove_markers(app, &buffer, handle);
        
        view_set_cursor(app, &view, seek_pos(next_cursor_marker.pos), true);
    }
}

/* END */

/* BEGIN CODE COPIED FROM https://4coder.handmade.network/forums/t/2430-made_a_comment_toggle_command */

CUSTOM_COMMAND_SIG(cro_comment_toggle){
    View_Summary view = get_active_view(app, AccessOpen);    
    Buffer_Summary buffer = get_buffer(app, view.buffer_id, AccessOpen);
    
    if(cro_selection_active) {
        int min_line, max_line;
        if (view.cursor.line > view.mark.line) {
            min_line = view.mark.line;
            max_line = view.cursor.line;
            if (view.cursor.character == 1) max_line--;
        } else {
            max_line = view.mark.line;
            min_line = view.cursor.line; 
            if (view.mark.character == 1) max_line--;
        }
        
        bool is_commenting = false;
        for(int line_number=min_line; line_number<=max_line; line_number++) {
            int pos = buffer_get_line_start(app, &buffer, line_number);
            char line_start[2];
            if (buffer_read_range(app, &buffer, pos, pos+2, line_start)) {
                if (!(line_start[0]=='/' && line_start[1]=='/')) {is_commenting=true; break; }
            }
        }
        for(int line_number=min_line; line_number<=max_line; line_number++) {
            int pos = buffer_get_line_start(app, &buffer, line_number);
            if (is_commenting) {
                buffer_replace_range(app, &buffer, pos, pos, "//", 2);
            } else {
                buffer_replace_range(app, &buffer, pos, pos+2, 0, 0);
            }
        }
        if (view.cursor.line > view.mark.line) {
            int min_pos = buffer_get_line_start(app, &buffer, min_line);
            int max_pos = buffer_get_line_end  (app, &buffer, max_line);
            view_set_cursor(app, &view, seek_pos(min_pos), true);
            view_set_mark  (app, &view, seek_pos(max_pos));
            view_set_highlight(app, &view, min_pos, max_pos, true);
        } else {
            int min_pos = buffer_get_line_start(app, &buffer, min_line);
            int max_pos = buffer_get_line_end  (app, &buffer, max_line);
            view_set_mark  (app, &view, seek_pos(max_pos));
            view_set_cursor(app, &view, seek_pos(min_pos), true);
            view_set_highlight(app, &view, min_pos, max_pos, true);
        }
    } else {
        auto pos = buffer_get_line_start(app, &buffer, view.cursor.line); // - Np3w: seek_line_beginning returns the wrong position in some cases?
        //auto pos = seek_line_beginning(app, &buffer, view.cursor.pos);
        
        
        char line_start[2];
        buffer_read_range(app, &buffer, pos, pos+2, line_start);
        if (line_start[0]=='/' && line_start[1]=='/') {
            buffer_replace_range(app, &buffer, pos, pos+2, 0, 0);
        } else {
            buffer_replace_range(app, &buffer, pos, pos, "//", 2);
        }
    }
}

/* END OF COPIED CODE */







static void swap_uint32(uint32_t *a, uint32_t *b){
    uint32_t tmp = *a;
    *a = *b;
    *b = tmp;
}

static uint32_t colormul(uint32_t color, float value){
    uint32_t r = (uint32_t)((float)((color >> 16) & 0xFF) * value);
    uint32_t g = (uint32_t)((float)((color >> 8 ) & 0xFF) * value);
    uint32_t b = (uint32_t)((float)((color >> 0 ) & 0xFF) * value);
    
    return 0xFF000000 | (r << 16) | (g << 8) | b;
}

#define NP_COLOR_SOLARIZED 1
#define NP_COLOR_A 2

#define COLOR_SCHEME NP_COLOR_SOLARIZED

static void np3w_set_colors(Application_Links *app, bool dark){
    // NOTE(Np3w): Based on solarized color scheme
    
    if(COLOR_SCHEME == NP_COLOR_SOLARIZED){
        uint32_t base03 = 0xFF002b36;
        uint32_t base02 = 0xFF073642;
        uint32_t base01 = 0xFF586e75;
        uint32_t base00 = 0xFF657b83;
        
        uint32_t base0  = 0xFF839496;
        uint32_t base1  = 0xFF93a1a1;
        uint32_t base2  = 0xFFeee8d5;
        uint32_t base3  = 0xFFfdf6e3;
        
        if(dark){
            swap_uint32(&base03, &base3);
            swap_uint32(&base02, &base2);
            swap_uint32(&base01, &base1);
            swap_uint32(&base00, &base0);
            
            print_message(app, literal("Dark theme"));
        }
        else{
            print_message(app, literal("Light theme"));
        }
        
        uint32_t yellow  = 0xFFb58900;
        uint32_t orange  = 0xFFcb4b16;
        uint32_t red     = 0xFFdc322f;
        uint32_t magenta = 0xFFd33682;
        uint32_t violet  = 0xFF6c71c4;
        uint32_t blue    = 0xFF268bd2;
        uint32_t cyan    = 0xFF2aa198;
        uint32_t green   = 0xFF859900;
        
        uint32_t a = base2;
        uint32_t b = base1;
        uint32_t c = base0;
        
        Theme_Color colors[] = {
            Stag_Back              , base3,
            Stag_Cursor            , base02,
            Stag_Highlight         , base2,
            Stag_Default           , dark ? base0 : colormul(base0, 0.5f)/*make it a bit darker*/,
            Stag_At_Cursor         , base2,
            Stag_Comment           , base1,
            
            Stag_Keyword           , green,
            Stag_Str_Constant      , cyan,
            Stag_Char_Constant     , red,
            Stag_Int_Constant      , magenta,
            Stag_Float_Constant    , magenta,
            Stag_Bool_Constant     , red,
            Stag_Include           , orange,
            Stag_Preproc           , orange,
            
            Stag_At_Highlight      , 0xFFCDAA7D,
            Stag_Mark              , 0xFF808080,
            Stag_Special_Character , 0xFFFF0000,
            Stag_Ghost_Character   , 0xFF5B4D3C,
            Stag_Paste             , 0xFFFFBB00,
            Stag_Undo              , 0xFF80005D,
            Stag_Highlight_Junk    , 0xFF3A0000,
            Stag_Highlight_White   , 0xFF003A3A,
            Stag_Bar               , 0xFFCACACA,
            Stag_Bar_Active        , 0xFFA8A8A8,
            Stag_Base              , 0xFF000000,
            Stag_Pop1              , 0xFF03CF0C,
            Stag_Pop2              , 0xFFFF0000,
            
            Stag_Margin            , a,
            Stag_Margin_Hover      , b,
            Stag_Margin_Active     , c,
            
            Stag_List_Item         , a,
            Stag_List_Item_Hover   , b,
            Stag_List_Item_Active  , c,
            
        };
        set_theme_colors(app, colors, ArrayCount(colors));
    }else if(COLOR_SCHEME == NP_COLOR_A){
#if 0
        Theme_Color colors[] = {
            Stag_Back              , 0xcccccc,
            Stag_Cursor            , base02,
            Stag_Highlight         , base2,
            Stag_Default           , dark ? base0 : colormul(base0, 0.5f)/*make it a bit darker*/,
            Stag_At_Cursor         , base2,
            Stag_Comment           , base1,
            
            Stag_Keyword           , green,
            Stag_Str_Constant      , cyan,
            Stag_Char_Constant     , red,
            Stag_Int_Constant      , magenta,
            Stag_Float_Constant    , magenta,
            Stag_Bool_Constant     , red,
            Stag_Include           , orange,
            Stag_Preproc           , orange,
            
            Stag_At_Highlight      , 0xFFCDAA7D,
            Stag_Mark              , 0xFF808080,
            Stag_Special_Character , 0xFFFF0000,
            Stag_Ghost_Character   , 0xFF5B4D3C,
            Stag_Paste             , 0xFFFFBB00,
            Stag_Undo              , 0xFF80005D,
            Stag_Highlight_Junk    , 0xFF3A0000,
            Stag_Highlight_White   , 0xFF003A3A,
            Stag_Bar               , 0xFFCACACA,
            Stag_Bar_Active        , 0xFFA8A8A8,
            Stag_Base              , 0xFF000000,
            Stag_Pop1              , 0xFF03CF0C,
            Stag_Pop2              , 0xFFFF0000,
            
            Stag_Margin            , a,
            Stag_Margin_Hover      , b,
            Stag_Margin_Active     , c,
            
            Stag_List_Item         , a,
            Stag_List_Item_Hover   , b,
            Stag_List_Item_Active  , c,
            
        };
#endif
    }
}
// Use my own implementation of this so I can add commands
CUSTOM_COMMAND_SIG(np3w_execute_arbitrary_command){
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
    
    if (match_ss(bar.string, make_lit_string("load project")) || match_ss(bar.string, make_lit_string("lp"))){
        exec_command(app, load_project);
        // NOTE(Np3w): Actually open all the code
        exec_command(app, open_all_code_recursive);
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
    else if(match_ss(bar.string, make_lit_string("light color"))){
        np3w_set_colors(app, false);
    }
    else if(match_ss(bar.string, make_lit_string("dark color"))){
        np3w_set_colors(app, true);
    }
    else{
        print_message(app, literal("unrecognized command\n"));
    }
}


CUSTOM_COMMAND_SIG(np3w_delete_until_end_of_line){
    View_Summary view = get_active_view(app, AccessOpen);
    Buffer_Summary buffer = get_buffer(app, view.buffer_id, AccessOpen);
    
    int32_t start = view.cursor.pos;
    int32_t end = buffer_get_line_end(app, &buffer, view.cursor.line);
    
    buffer_replace_range(app, &buffer, start, end, 0, 0);
}

CUSTOM_COMMAND_SIG(np3w_cut_until_end_of_line){
    View_Summary view = get_active_view(app, AccessOpen);
    Buffer_Summary buffer = get_buffer(app, view.buffer_id, AccessOpen);
    
    int32_t start = view.cursor.pos;
    int32_t end = buffer_get_line_end(app, &buffer, view.cursor.line);
    
    clipboard_copy(app, start, end, &buffer, AccessOpen);
    
    buffer_replace_range(app, &buffer, start, end, 0, 0);
}
CUSTOM_COMMAND_SIG(np3w_cut_line){
    View_Summary view = get_active_view(app, AccessOpen);
    Buffer_Summary buffer = get_buffer(app, view.buffer_id, AccessOpen);
    
    int32_t start = buffer_get_line_start(app, &buffer, view.cursor.line);
    int32_t end = buffer_get_line_end(app, &buffer, view.cursor.line);
    
    clipboard_copy(app, start, end, &buffer, AccessOpen);
    
    buffer_replace_range(app, &buffer, start, end, 0, 0);
}


CUSTOM_COMMAND_SIG(np3w_copy_until_end_of_line){
    View_Summary view = get_active_view(app, AccessOpen);
    Buffer_Summary buffer = get_buffer(app, view.buffer_id, AccessOpen);
    
    int32_t start = view.cursor.pos;
    int32_t end = buffer_get_line_end(app, &buffer, view.cursor.line);
    
    clipboard_copy(app, start, end, &buffer, AccessOpen);
}
CUSTOM_COMMAND_SIG(np3w_copy_line){
    View_Summary view = get_active_view(app, AccessOpen);
    Buffer_Summary buffer = get_buffer(app, view.buffer_id, AccessOpen);
    
    int32_t start = buffer_get_line_start(app, &buffer, view.cursor.line);
    int32_t end = buffer_get_line_end(app, &buffer, view.cursor.line);
    
    clipboard_copy(app, start, end, &buffer, AccessOpen);
}

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
    //bind(context, 'd', MDFR_ALT, open_debug);
    
    bind(context, '.', MDFR_ALT, change_to_build_panel);
    bind(context, ',', MDFR_ALT, close_build_panel);
    bind(context, 'n', MDFR_ALT, goto_next_error);
    bind(context, 'N', MDFR_ALT, goto_prev_error);
    bind(context, 'M', MDFR_ALT, goto_first_error);
    bind(context, 'm', MDFR_ALT, build_in_build_panel);
    
    bind(context, 'z', MDFR_ALT, execute_any_cli);
    bind(context, 'Z', MDFR_ALT, execute_previous_cli);
    
    bind(context, 'x', MDFR_ALT, np3w_execute_arbitrary_command);
    
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
    
    // Delete, cut and copy
    bind(context, 'd', MDFR_CTRL, delete_range);
    bind(context, 'D', MDFR_CTRL, np3w_delete_until_end_of_line);
    bind(context, 'D', MDFR_ALT,  delete_line);
    
    bind(context, 'x', MDFR_CTRL, cut);
    bind(context, 'X', MDFR_CTRL, np3w_cut_until_end_of_line);
    bind(context, 'X', MDFR_ALT,  np3w_cut_line);
    
    bind(context, 'c', MDFR_CTRL, copy);
    bind(context, 'C', MDFR_CTRL, np3w_copy_until_end_of_line);
    bind(context, 'C', MDFR_ALT, np3w_copy_line);
    
    
    
    
    bind(context, 'e', MDFR_CTRL, center_view);
    bind(context, 'E', MDFR_CTRL, left_adjust_view);
    bind(context, 'f', MDFR_CTRL, search);
    bind(context, 'F', MDFR_CTRL, list_all_locations);
    bind(context, 'F', MDFR_ALT, list_all_substring_locations_case_insensitive);
    bind(context, 'g', MDFR_CTRL, goto_line);
    bind(context, 'j', MDFR_CTRL, to_lowercase);
    bind(context, 'K', MDFR_CTRL, kill_buffer);
    
    
    
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
    
    
    bind(context, 'V', MDFR_CTRL, paste_next_and_indent);
    
    
    
    // Toggle stuff
    bind(context, 'v', MDFR_ALT, toggle_virtual_whitespace);
    bind(context, 'l', MDFR_ALT, toggle_line_wrap);
    
    
    bind(context, 'y', MDFR_CTRL, redo);
    bind(context, 'z', MDFR_CTRL, undo);
    
    bind(context, '2', MDFR_CTRL, decrease_line_wrap);
    bind(context, '3', MDFR_CTRL, increase_line_wrap);
    
    bind(context, '?', MDFR_CTRL, toggle_show_whitespace);
    bind(context, '~', MDFR_CTRL, clean_all_lines);
    bind(context, '\n', MDFR_NONE, newline_or_goto_position);
    bind(context, '\n', MDFR_SHIFT, newline_or_goto_position_same_panel);
    bind(context, ' ', MDFR_SHIFT, write_character);
    
    /* Croepha selection bindings */
    
    bind_vanilla_keys(context, cro_selection_write_character);
    
    
#define __(_k, _m, _f) \
    bind(context, _k, _m|MDFR_SHIFT, [](Application_Links* app){cro_selection_cont(app, _f);}); \
    bind(context, _k, _m, [](Application_Links* app){cro_selection_abort(app); _f(app);})
    __(key_left,      MDFR_NONE, move_left);
    __(key_right,     MDFR_NONE, move_right);
    __(key_up,        MDFR_NONE, move_up);
    __(key_down,      MDFR_NONE, move_down);
    __(key_end,       MDFR_NONE, seek_end_of_line);
    __(key_home,      MDFR_NONE, seek_beginning_of_line);
    __(key_page_up,   MDFR_NONE, page_up);
    __(key_page_down, MDFR_NONE, page_down);
    __(key_right,     MDFR_CTRL|MDFR_ALT, seek_whitespace_right);
    __(key_left,      MDFR_CTRL|MDFR_ALT, seek_whitespace_left);
    __(key_right,     MDFR_CTRL, seek_token_right); // ?
    __(key_left,      MDFR_CTRL, seek_token_left); // ?
    __(key_right,     MDFR_ALT,  seek_white_or_token_right);
    __(key_left,      MDFR_ALT,  seek_white_or_token_left);
    __(key_up,        MDFR_CTRL, seek_whitespace_up_end_line);
    __(key_down,      MDFR_CTRL, seek_whitespace_down_end_line);
    __(key_up,        MDFR_ALT,  move_up_10);
    __(key_down,      MDFR_ALT,  move_down_10);
#undef __
    
    //    bind(context, key_del, MDFR_SHIFT, delete_char);
    bind(context, key_back, MDFR_NONE, [](Application_Links* app){
         cro_selection_delete_or_cmd(app, backspace_char);
         });
    bind(context, key_del, MDFR_NONE, [](Application_Links* app){
         cro_selection_delete_or_cmd(app, delete_char);
         });
    bind(context, key_esc, MDFR_NONE, cro_selection_abort);         
    bind(context, 'x', MDFR_CTRL, [](Application_Links* app){
         cut(app);
         cro_selection_abort(app);
         });
    bind(context, 'v', MDFR_CTRL, [](Application_Links* app){
         cro_selection_delete_or_cmd(app, NULL);
         paste_and_indent(app);
         });
    
    bind(context, ' ', MDFR_SHIFT, cro_selection_write_character);
    
    /* End of Croepha selection bindings */
    
    /* Croepha comment toggle bindings */
    bind(context, 'l', MDFR_CTRL, cro_comment_toggle);
    /* End of Croepha comment toggle bindings */
    
    
    /* Np3w bookmark bindings */
    bind(context, 'b', MDFR_CTRL, np_set_bookmark_at_cursor);
    bind(context, 'B', MDFR_CTRL, np_interactive_goto_bookmark);
    /* End of Np3w bookmark bindings */
    
    end_map(context);
}

START_HOOK_SIG(np3w_init){
    default_4coder_initialize(app);
    //default_4coder_side_by_side_panels(app, files, file_count);
    
    if (automatically_load_project){
        load_project(app);
    }
    
    //np3w_set_colors(app, true);
    //change_theme(app, literal("Handmade Hero"));
    //change_theme(app, literal("stb"));
    change_theme(app, literal("Np3w"));
    
    return(0);
}

OPEN_FILE_HOOK_SIG(np3w_new_file){
    Buffer_Summary buffer = get_buffer(app, buffer_id, AccessOpen);
    
    int afterSlashP = buffer.file_name_len;
    while(afterSlashP > 0 && buffer.file_name[afterSlashP - 1] != '/' && buffer.file_name[afterSlashP - 1] != '\\'){
        afterSlashP -= 1;
    }
    
    char buf[256];
    sprintf(buf,
            "/*\n"
            "%.*s - \n"
            "\n"
            "*/\n"
            "\n",
            buffer.file_name_len - afterSlashP, buffer.file_name + afterSlashP);
    
    buffer_replace_range(app, &buffer, 0, 0, buf, strlen(buf));
    
    // no meaning for return
    return(0);
}


#ifndef NO_BINDING
extern "C" int32_t
get_bindings(void *data, int32_t size){
    Bind_Helper context_ = begin_bind_helper(data, size);
    Bind_Helper *context = &context_;
    
    set_all_default_hooks(context);
    default_keys(context);
    
    set_start_hook(context, np3w_init);
    set_new_file_hook(context, np3w_new_file);
    
    int32_t result = end_bind_helper(context);
    return(result);
}
#endif //NO_BINDING

#endif //FCODER_DEFAULT_BINDINGS

// BOTTOM

