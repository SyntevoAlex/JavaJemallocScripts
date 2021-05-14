#!/bin/bash

JEPROF_IGNORES=()

# ----------------
# fontconfig
# ----------------

# 'FcConfigEnsure()' initializes a global variable '_fcConfig' in 'fontconfig'.
# Example stack:
#   malloc
#   strdup (strdup.c:42)
#   FcExprCreateString (fcxml.c:131)
#   FcParseFamily (fcxml.c:1745)
#   FcEndElement (fcxml.c:2999)
#   doContent (xmlparse.c:2845)
#   contentProcessor (xmlparse.c:2445)
#   doProlog (xmlparse.c:4371)
#   prologProcessor (xmlparse.c:4094)
#   XML_ParseBuffer (xmlparse.c:1893)
#   XML_ParseBuffer (xmlparse.c:1863)
#   FcConfigParseAndLoadFromMemoryInternal (fcxml.c:3358)
#   _FcConfigParse (fcxml.c:3491)
#   FcConfigParseAndLoadDir (fcxml.c:3256)
#   _FcConfigParse (fcxml.c:3454)
#   FcParseInclude (fcxml.c:2421)
#   FcEndElement (fcxml.c:2971)
#   doContent (xmlparse.c:2845)
#   contentProcessor (xmlparse.c:2445)
#   doProlog (xmlparse.c:4371)
#   prologProcessor (xmlparse.c:4094)
#   XML_ParseBuffer (xmlparse.c:1893)
#   XML_ParseBuffer (xmlparse.c:1863)
#   FcConfigParseAndLoadFromMemoryInternal (fcxml.c:3358)
#   _FcConfigParse (fcxml.c:3491)
#   FcInitLoadOwnConfig (fcinit.c:88)
#   FcInitLoadOwnConfigAndFonts (fcinit.c:169)
#   FcConfigEnsure (fccfg.c:45)
#   IA__FcConfigGetCurrent (fccfg.c:524)
#   FcConfigSubstituteWithPat (fccfg.c:1575)
#   pango_cairo_fc_font_map_fontset_key_substitute (pangocairo-fcfontmap.c:106)
#   pango_fc_default_substitute (pangofc-fontmap.c:1685)
#   pango_fc_font_map_get_patterns (pangofc-fontmap.c:1740)
#   pango_fc_font_map_load_fontset (pangofc-fontmap.c:1844)
#   itemize_state_update_for_new_run (pango-context.c:1407)
#   itemize_state_process_run (pango-context.c:1431)
#   pango_itemize_with_base_dir (pango-context.c:1575)
#   pango_layout_check_lines (pango-layout.c:4279)
#   pango_layout_check_lines (pango-layout.c:4175)
#   pango_layout_get_unknown_glyphs_count (pango-layout.c:1291)
#   find_invisible_char (gtkentry.c:2763)
JEPROF_IGNORES+=("FcConfigEnsure")

# ----------------
# gettext
# ----------------

# Values returned by gettext() seem to be permanently cached.
# The documentation says nothing about freeing them.
# Example stack:
#   textdomain (??:?)
#   textdomain (??:?)
#   textdomain (??:?)
#   ngettext (??:?)
#   gettext (??:?)
#   g_key_file_get_locale_string (glib/gkeyfile.c:2337)
#   g_desktop_app_info_load_from_keyfile (gio/gdesktopappinfo.c:1797)
#   g_desktop_app_info_new_from_filename (gio/gdesktopappinfo.c:1898)
#   g_app_info_get_all (gio/gdesktopappinfo.c:1001)
JEPROF_IGNORES+=("gettext")

# ----------------
# glibc
# ----------------

# Ignore everything that happens when loading a shared library
JEPROF_IGNORES+=("dlopen")

# ----------------
# GTK
# ----------------

# Most leak stacks from 'get_xkb()' also contain 'XkbGetMap()'. The correct
# way to free it is 'XkbFreeClientMap()', but GTK has no mentions of it. I
# therefore understand that this is supposed to be cached forever in GTK.
JEPROF_IGNORES+=("get_xkb")

# Ignore everything that happens in massive inializers.
# For example, GTK will load theme's XML there, which causes thousands of
# allocations that won't go away.
# Example stack:
#   realloc
#   g_realloc (gmem.c:167)
#   g_array_maybe_expand (garray.c:962)
#   g_array_append_vals (garray.c:479)
#   css_provider_commit (gtkcssprovider.c:933)
#   parse_ruleset (gtkcssprovider.c:1633)
#   parse_statement (gtkcssprovider.c:1644)
#   parse_stylesheet (gtkcssprovider.c:1660)
#   gtk_css_provider_load_internal (gtkcssprovider.c:1787)
#   parse_import (gtkcssprovider.c:1053)
#   parse_at_keyword (gtkcssprovider.c:1301)
#   parse_statement (gtkcssprovider.c:1642)
#   parse_stylesheet (gtkcssprovider.c:1660)
#   gtk_css_provider_load_internal (gtkcssprovider.c:1787)
#   gtk_css_provider_load_from_file (gtkcssprovider.c:1890)
#   gtk_css_provider_load_from_path (gtkcssprovider.c:1924)
#   _gtk_css_provider_load_named (gtkcssprovider.c:2166)
#   settings_update_theme (gtksettings.c:3309)
#   settings_init_style (gtksettings.c:1899)
#   gtk_settings_create_for_display (gtksettings.c:1985)
#   gtk_settings_get_for_display (gtksettings.c:2017)
#   display_opened_cb (gtkmodules.c:498)
#   g_cclosure_marshal_VOID__OBJECTv (gmarshal.c:1910)
#   _g_closure_invoke_va (gclosure.c:873)
#   g_signal_emit_valist (gsignal.c:3408)
#   g_signal_emit (gsignal.c:3555)
#   _g_closure_invoke_va (gclosure.c:873)
#   g_signal_emit_valist (gsignal.c:3408)
#   g_signal_emit_by_name (gsignal.c:3595)
#   _gdk_x11_display_open (gdkdisplay-x11.c:1803)
JEPROF_IGNORES+=("gtk_settings_create_for_display")

# gtk_im_module_initialize() is an internal one-time initializer in GTK
# that allocates various permanent global variables.
# Example stack:
#   malloc
#   g_malloc (gmem.c:102)
#   g_slice_alloc (gslice.c:1025)
#   g_slice_alloc0 (gslice.c:1051)
#   g_type_create_instance (gtype.c:1850)
#   g_object_new_internal (gobject.c:1937)
#   g_object_new_with_properties (gobject.c:2105)
#   g_object_new (gobject.c:1777)
#   gtk_im_module_initialize (gtkimmodule.c:448)
#   _gtk_im_module_get_default_context_id (gtkimmodule.c:841)
#   get_effective_context_id (gtkimmulticontext.c:260)
#   get_effective_context_id (gtkimmulticontext.c:252)
#   gtk_im_multicontext_get_slave (gtkimmulticontext.c:270)
#   gtk_im_multicontext_get_preedit_string (gtkimmulticontext.c:343)
#   gtk_im_context_get_preedit_string (gtkimcontext.c:496)
#   gtk_entry_create_layout (gtkentry.c:6365)
#   gtk_entry_ensure_layout (gtkentry.c:6457)
#   gtk_entry_get_cursor_locations.constprop.0 (gtkentry.c:6888)
#   update_im_cursor_location (gtkentry.c:6254)
#   gtk_entry_recompute (gtkentry.c:6285)
#   g_cclosure_marshal_VOID__OBJECTv (gmarshal.c:1910)
#   _g_closure_invoke_va (gclosure.c:873)
#   g_signal_emit_valist (gsignal.c:3408)
#   g_signal_emit (gsignal.c:3555)
JEPROF_IGNORES+=("gtk_im_module_initialize")

# gtk_init_check() is another large-scale one-time initializer.
# For simplicity, let's just ignore anything it does.
# Example stack:
#   malloc
#   XRenderQueryFormats (Xrender.c:468)
#   XRenderQueryVersion (Xrender.c:333)
#   _XcursorGetDisplayInfo (display.c:144)
#   _XcursorGetDisplayInfo (display.c:96)
#   XcursorGetTheme (display.c:351)
#   gdk_x11_display_set_cursor_theme (gdkcursor-x11.c:475)
#   settings_update_cursor_theme (gtksettings.c:3052)
#   gtk_settings_create_for_display (gtksettings.c:1989)
#   gtk_settings_get_for_display (gtksettings.c:2017)
#   display_opened_cb (gtkmodules.c:498)
#   g_cclosure_marshal_VOID__OBJECTv (gmarshal.c:1910)
#   _g_closure_invoke_va (gclosure.c:873)
#   g_signal_emit_valist (gsignal.c:3408)
#   g_signal_emit (gsignal.c:3555)
#   _g_closure_invoke_va (gclosure.c:873)
#   g_signal_emit_valist (gsignal.c:3408)
#   g_signal_emit_by_name (gsignal.c:3595)
#   _gdk_x11_display_open (gdkdisplay-x11.c:1803)
#   gdk_display_manager_open_display (gdkdisplaymanager.c:462)
#   gtk_init_check (gtkmain.c:1109)
#   gtk_init_check (gtkmain.c:1101)
JEPROF_IGNORES+=("gtk_init_check")

# gtk_test_register_all_types() is another one-time initializer.
# Example stack:
#   realloc
#   g_realloc (gmem.c:167)
#   type_set_qdata_W (gtype.c:3737)
#   type_iface_add_prerequisite_W (gtype.c:1536)
#   g_type_interface_add_prerequisite (gtype.c:1620)
#   gtk_tree_sortable_get_type (gtktreesortable.c:63)
#   gtk_list_store_get_type_once (gtkliststore.c:298)
#   gtk_list_store_get_type (gtkliststore.c:298)
#   gtk_test_register_all_types (gtktypefuncs.inc:304)
#   gtk_builder_real_get_type_from_name (gtkbuilder.c:443)
#   gtk_builder_real_get_type_from_name (gtkbuilder.c:430)
#   gtk_builder_get_type_from_name (gtkbuilder.c:2410)
#   parse_object (gtkbuilderparser.c:289)
#   start_element (gtkbuilderparser.c:962)
#   emit_start_element (gmarkup.c:1064)
#   g_markup_parse_context_parse (gmarkup.c:1423)
#   _gtk_builder_parser_parse_buffer (gtkbuilderparser.c:1261)
#   gtk_builder_extend_with_template (gtkbuilder.c:1178)
#   gtk_widget_init_template (gtkwidget.c:17024)
#   gtk_tooltip_window_init (gtktooltipwindow.c:80)
#   g_type_create_instance (gtype.c:1868)
#   g_object_new_internal (gobject.c:1937)
#   g_object_new_valist (gobject.c:2262)
JEPROF_IGNORES+=("gtk_test_register_all_types")

# gtk_*_class_init() are internal GLib initializers for GTK classes.
# These are called automatically on the first use of class, such as g_object_new().
# Example stack
#   realloc
#   g_realloc (gmem.c:167)
#   g_hash_table_realloc_key_or_value_array (ghash.c:380)
#   realloc_arrays (ghash.c:723)
#   g_hash_table_resize (ghash.c:876)
#   g_hash_table_maybe_resize (ghash.c:916)
#   g_hash_table_insert_node (ghash.c:1342)
#   g_hash_table_insert_internal (ghash.c:1601)
#   g_param_spec_pool_insert (gparam.c:968)
#   install_property_internal (gobject.c:580)
#   install_property_internal (gobject.c:566)
#   validate_and_install_class_property (gobject.c:617)
#   validate_and_install_class_property (gobject.c:602)
#   g_object_class_install_properties (gobject.c:770)
#   gtk_entry_class_init (gtkentry.c:1549)
#   gtk_entry_class_intern_init (gtkentry.c:731)
#   type_class_init_Wm (gtype.c:2236)
#   g_type_class_ref (gtype.c:2951)
#   g_object_new_with_properties (gobject.c:2075)
#   g_object_new (gobject.c:1777)
JEPROF_IGNORES+=("gtk_\w+_class_init")

# ----------------
# ibus
# ----------------

# One-time GLib initializers for IBus classes like:
# G_DEFINE_TYPE_WITH_PRIVATE (IBusInputContext, ibus_input_context, IBUS_TYPE_PROXY)
# Example stack:
#   realloc
#   g_realloc (gmem.c:167)
#   g_signal_newv (gsignal.c:1796)
#   g_signal_new_valist (gsignal.c:1988)
#   g_signal_new (gsignal.c:1517)
#   ibus_input_context_class_init (ibusinputcontext.c:481)
#   ibus_input_context_class_intern_init (ibusinputcontext.c:86)
#   type_class_init_Wm (gtype.c:2236)
#   g_type_class_ref (gtype.c:2951)
#   g_object_new_valist (gobject.c:2214)
#   g_async_initable_new_valist_async (gasyncinitable.c:430)
#   g_async_initable_new_async (gasyncinitable.c:343)
#   ibus_input_context_new_async (ibusinputcontext.c:780)
#   _create_input_context_async_step_one_done (ibusbus.c:947)
#   g_task_return_now (gtask.c:1214)
#   g_task_return.part.0 (gtask.c:1283)
#   g_dbus_connection_call_done (gdbusconnection.c:5764)
#   g_task_return_now (gtask.c:1214)
#   complete_in_idle_cb (gtask.c:1228)
#   g_main_dispatch (gmain.c:3309)
#   g_main_context_dispatch (gmain.c:3974)
#   g_main_context_iterate.isra.0 (gmain.c:4047)
#   g_main_context_iteration (gmain.c:4108)
#   gtk_main_iteration_do (gtkmain.c:1456)
JEPROF_IGNORES+=("ibus_\w+_class_init")

# ----------------
# JVM
# ----------------

# Ignore all sorts of JVM internal memory allocations
# Example stack:
#   malloc
#   AllocateHeap(unsigned long, MemoryType, NativeCallStack const&, AllocFailStrategy::AllocFailEnum) (allocation.cpp:44)
#   BasicHashtable<(MemoryType)1>::new_entry(unsigned int) (hashtable.cpp:68)
#   Hashtable<InstanceKlass*, (MemoryType)1>::new_entry(unsigned int, InstanceKlass*) (hashtable.cpp:84)
#   new_entry (loaderConstraints.cpp:49)
#   LoaderConstraintTable::add_entry(Symbol*, InstanceKlass*, Handle, InstanceKlass*, Handle) (loaderConstraints.cpp:241)
#   SystemDictionary::add_loader_constraint(Symbol*, Handle, Handle, Thread*) (systemDictionary.cpp:2286)
#   SystemDictionary::check_signature_loaders(Symbol*, Handle, Handle, bool, Thread*) (systemDictionary.cpp:2388)
#   LinkResolver::check_method_loader_constraints(LinkInfo const&, methodHandle const&, char const*, Thread*) (linkResolver.cpp:663)
#   LinkResolver::resolve_method(LinkInfo const&, Bytecodes::Code, Thread*) (linkResolver.cpp:789)
#   LinkResolver::linktime_resolve_static_method(LinkInfo const&, Thread*) (linkResolver.cpp:1086)
#   LinkResolver::resolve_static_call(CallInfo&, LinkInfo const&, bool, Thread*) (linkResolver.cpp:1061)
#   MethodHandles::resolve_MemberName(Handle, Klass*, bool, Thread*) (methodHandles.cpp:794)
#   SystemDictionary::link_method_handle_constant(Klass*, int, Klass*, Symbol*, Symbol*, Thread*) (systemDictionary.cpp:2753)
#   ConstantPool::resolve_constant_at_impl(constantPoolHandle const&, int, int, bool*, Thread*) (constantPool.cpp:1027)
#   resolve_possibly_cached_constant_at (constantPool.hpp:740)
#   ConstantPool::resolve_bootstrap_specifier_at_impl(constantPoolHandle const&, int, Thread*) (constantPool.cpp:1125)
#   resolve_bootstrap_specifier_at (constantPool.hpp:750)
#   LinkResolver::resolve_invokedynamic(CallInfo&, constantPoolHandle const&, int, Thread*) (linkResolver.cpp:1733)
#   LinkResolver::resolve_invoke(CallInfo&, Handle, constantPoolHandle const&, int, Bytecodes::Code, Thread*) (linkResolver.cpp:1617)
#   InterpreterRuntime::resolve_invokedynamic(JavaThread*) (interpreterRuntime.cpp:975)
#   InterpreterRuntime::resolve_from_cache(JavaThread*, Bytecodes::Code) (interpreterRuntime.cpp:1004)
JEPROF_IGNORES+=("AllocateHeap")

# Ignore all sorts of JVM internal memory allocations
# Example stack:
#   Chunk::operator new (hotspot/share/memory/arena.cpp:195)
#   Arena::Amalloc (hotspot/share/memory/arena.hpp:153)
#   Matcher::match (hotspot/share/opto/matcher.cpp:344)
#   Compile::Code_Gen (hotspot/share/opto/compile.cpp:2492)
#   Compile::Compile (hotspot/share/opto/compile.cpp:915)
#   C2Compiler::compile_method (hotspot/share/opto/c2compiler.cpp:110)
#   CompileBroker::invoke_compiler_on_method (hotspot/share/compiler/compileBroker.cpp:2192)
#   CompileBroker::compiler_thread_loop (hotspot/share/compiler/compileBroker.cpp:1879)
#   JavaThread::thread_main_inner (hotspot/share/runtime/thread.cpp:1860)
#   Thread::call_run (hotspot/share/runtime/thread.cpp:381)
#   thread_native_entry (hotspot/os/linux/os_linux.cpp:788)
#   start_thread (glibc-2.31/nptl/pthread_create.c:477)
JEPROF_IGNORES+=("Arena::Amalloc")

# Ignore all sorts of JVM internal memory allocations
# Example stack:
#   ChunkPool::allocate (hotspot/share/memory/arena.cpp:79 (discriminator 7))
#   Chunk::operator new (hotspot/share/memory/arena.cpp:190)
#   Arena::Amalloc (hotspot/share/memory/arena.hpp:153)
#   Node_Array::grow (hotspot/share/opto/node.cpp:2276)
#   Node_Array::map (hotspot/share/opto/node.hpp:1493)
#   PhaseChaitin::Register_Allocate (hotspot/share/opto/chaitin.cpp:590)
#   Compile::Code_Gen (hotspot/share/opto/compile.cpp:2528)
#   Compile::Compile (hotspot/share/opto/compile.cpp:915)
#   C2Compiler::compile_method (hotspot/share/opto/c2compiler.cpp:110)
#   CompileBroker::invoke_compiler_on_method (hotspot/share/compiler/compileBroker.cpp:2192)
#   CompileBroker::compiler_thread_loop (hotspot/share/compiler/compileBroker.cpp:1879)
#   JavaThread::thread_main_inner (hotspot/share/runtime/thread.cpp:1860)
#   Thread::call_run (hotspot/share/runtime/thread.cpp:381)
#   thread_native_entry (hotspot/os/linux/os_linux.cpp:788)
#   start_thread (glibc-2.31/nptl/pthread_create.c:477)
JEPROF_IGNORES+=("ChunkPool::allocate")

# Ignore stuff related to ZIP files, this is probably used in JAR loading
# Example stack:
#   inflate_ensure_window (./inflate.c:408)
#   doInflate (java.base/share/native/libzip/Inflater.c:140)
JEPROF_IGNORES+=("inflate_ensure_window")

# Ignore stuff related to ZIP files, this is probably used in JAR loading
# Example stack:
#   inflateInit2_ (./inflate.c:243)
#   Java_java_util_zip_Inflater_init (java.base/share/native/libzip/Inflater.c:67)
JEPROF_IGNORES+=("inflateInit2_")

# Ignore everything that happens when creating a VM
# Example stack:
#   Chunk::operator new (hotspot/share/memory/arena.cpp:195)
#   SymbolTable::initialize_symbols (hotspot/share/classfile/symbolTable.cpp:79 (discriminator 1))
#   SymbolTable::create_table (hotspot/share/classfile/symbolTable.hpp:178)
#   universe_init (hotspot/share/memory/universe.cpp:728)
#   init_globals (hotspot/share/runtime/init.cpp:111)
#   Threads::create_vm (hotspot/share/runtime/thread.cpp:3795)
#   JNI_CreateJavaVM (hotspot/share/prims/jni.cpp:3971)
#   InitializeJVM (java.base/share/native/libjli/java.c:1527)
#   call_continuation (java.base/unix/native/libjli/java_md_solinux.c:739)
#   start_thread (glibc-2.31/nptl/pthread_create.c:477)
JEPROF_IGNORES+=("Threads::create_vm")

# ----------------
# libx11
# ----------------

# When a block allocated by '_XEnq' is no longer needed, it's not freed but
# instead cached in 'Display::qfree'. This makes it look like a leak.
JEPROF_IGNORES+=("_XEnq")

# ----------------
# pango
# ----------------

# This initializes glyph caches for the font.
# I understand that GTK never releases at least the system font, hence this
# cache becomes a leak. Just ignore it. Hopefully if there's a font leak that
# will be indicated by other leaks that are not suppressed.
# Example stack
#   malloc
#   _cairo_scaled_font_map_lock (cairo-scaled-font.c:371)
#   cairo_scaled_font_create (cairo-scaled-font.c:1034)
#   _pango_cairo_font_private_get_scaled_font (pangocairo-font.c:83)
#   _pango_cairo_font_private_get_scaled_font (pangocairo-font.c:64)
#   _pango_cairo_font_private_glyph_extents_cache_init (pangocairo-font.c:787)
#   _pango_cairo_font_private_get_glyph_extents (pangocairo-font.c:879)
#   pango_hb_font_get_glyph_h_advance (pangofc-shape.c:218)
#   pango_hb_font_get_glyph_h_advance (pangofc-shape.c:207)
#   UnknownInlinedFun (hb-font.hh:250)
#   hb_font_get_glyph_h_advances_default(hb_font_t*, void*, unsigned int, unsigned int const*, unsigned int, int*, unsigned int, void*) (hb-font.cc:240)
#   get_glyph_h_advances (hb-font.hh:268)
#   hb_ot_position_default (hb-ot-shape.cc:887)
#   hb_ot_position (hb-ot-shape.cc:995)
#   hb_ot_shape_internal (hb-ot-shape.cc:1068)
#   _hb_ot_shape (hb-ot-shape.cc:1091)
#   hb_shape_plan_execute (hb-shaper-list.hh:42)
#   hb_shape_full (hb-shape.cc:139)
#   pango_hb_shape (pangofc-shape.c:387)
#   pango_shape_with_flags (shape.c:205)
#   shape_run (pango-layout.c:3354)
#   process_item (pango-layout.c:3633)
#   process_line (pango-layout.c:3951)
#   pango_layout_check_lines (pango-layout.c:4315)
#   pango_layout_check_lines (pango-layout.c:4175)
#   pango_layout_get_unknown_glyphs_count (pango-layout.c:1291)
#   find_invisible_char (gtkentry.c:2763)
#   gtk_entry_update_cached_style_values (gtkentry.c:5290)
#   gtk_entry_init (gtkentry.c:2822)
#   g_type_create_instance (gtype.c:1868)
#   g_object_new_internal (gobject.c:1937)
#   g_object_new_with_properties (gobject.c:2105)
#   g_object_new (gobject.c:1777)
JEPROF_IGNORES+=("_pango_cairo_font_private_get_glyph_extents")

# ----------------
# rsvg
# ----------------

# RSVG gets involved whenever GTK deals with SVG images.
# One example is 'Yaru' theme on Ubuntu which has SVG images for checkboxes.
# Just like the name implies, 'call_once' are various one-time initializers.
# Example stack:
#   calloc
#   UnknownInlinedFun (alloc.rs:162)
#   UnknownInlinedFun (alloc.rs:209)
#   allocate_in<usize,alloc::alloc::Global> (raw_vec.rs:87)
#   with_capacity_zeroed<usize> (raw_vec.rs:147)
#   from_elem<usize> (vec.rs:1765)
#   from_elem<usize> (vec.rs:1730)
#   __static_ref_initialize (dynamic_set.rs:45)
#   call_once<fn() -> std::sync::mutex::Mutex<string_cache::dynamic_set::Set>,()> (function.rs:232)
#   {{closure}}<std::sync::mutex::Mutex<string_cache::dynamic_set::Set>,fn() -> std::sync::mutex::Mutex<string_cache::dynamic_set::Set>> (inline_lazy.rs:31)
#   std::sync::once::Once::call_once::{{closure}} (once.rs:264)
#   std::sync::once::Once::call_inner (once.rs:416)
#   call_once<closure-0> (once.rs:264)
#   get<std::sync::mutex::Mutex<string_cache::dynamic_set::Set>,fn() -> std::sync::mutex::Mutex<string_cache::dynamic_set::Set>> (inline_lazy.rs:30)
#   __stability (<::lazy_static::__lazy_static_internal macros>:16)
#   <string_cache::dynamic_set::DYNAMIC_SET as core::ops::deref::Deref>::deref (<::lazy_static::__lazy_static_internal macros>:18)
#   <string_cache::atom::Atom<Static> as core::convert::From<alloc::borrow::Cow<str>>>::from (atom.rs:194)
#   UnknownInlinedFun (trivial_impls.rs:48)
#   call_once<fn(&str) -> string_cache::atom::Atom<markup5ever::PrefixStaticSet>,(&str)> (function.rs:232)
#   map<&str,string_cache::atom::Atom<markup5ever::PrefixStaticSet>,fn(&str) -> string_cache::atom::Atom<markup5ever::PrefixStaticSet>> (option.rs:456)
#   rsvg_internals::property_bag::PropertyBag::new_from_xml2_attributes (property_bag.rs:63)
#   rsvg_internals::xml2_load::sax_start_element_ns_cb (xml2_load.rs:218)
#   xmlParseStartTag2 (parser.c:9589)
#   xmlParseElementStart (parser.c:9962)
#   xmlParseElement__internal_alias (parser.c:9910)
#   xmlParseDocument (parser.c:10748)
#   rsvg_internals::xml2_load::Xml2Parser::parse (xml2_load.rs:450)
#   {{closure}} (xml.rs:590)
#   and_then<alloc::boxed::Box<rsvg_internals::xml2_load::Xml2Parser>,rsvg_internals::error::LoadingError,(),closure-0> (result.rs:727)
#   rsvg_internals::xml::XmlState::parse_from_stream (xml.rs:589)
#   build_document (xml.rs:603)
#   rsvg_internals::xml::xml_load_from_possibly_compressed_stream (xml.rs:701)
#   rsvg_internals::document::Document::load_from_stream (document.rs:55)
#   rsvg_internals::handle::Handle::from_stream (handle.rs:94)
#   rsvg_c_api::c_api::CHandle::read_stream (c_api.rs:743)
#   close (c_api.rs:709)
#   rsvg_rust_handle_close (c_api.rs:1285)
#   gdk_pixbuf__svg_image_stop_load (io-svg.c:160)
#   gdk_pixbuf_loader_close (gdk-pixbuf-loader.c:846)
#   load_from_stream (gdkpixbufutils.c:54)
#   _gdk_pixbuf_new_from_stream_scaled (gdkpixbufutils.c:104)
#   _gdk_pixbuf_new_from_resource_scaled (gdkpixbufutils.c:127)
#   icon_info_ensure_scale_and_pixbuf (gtkicontheme.c:3924)
#   icon_info_ensure_scale_and_pixbuf (gtkicontheme.c:3854)
#   gtk_icon_info_load_symbolic_svg (gtkicontheme.c:4528)
#   gtk_icon_info_load_symbolic_internal (gtkicontheme.c:4658)
#   gtk_css_image_recolor_load (gtkcssimagerecolor.c:118)
#   gtk_css_image_recolor_compute (gtkcssimagerecolor.c:170)
#   gtk_css_image_fallback_compute (gtkcssimagefallback.c:149)
#   gtk_css_image_fallback_compute (gtkcssimagefallback.c:132)
#   gtk_css_value_image_compute (gtkcssimagevalue.c:50)
#   gtk_css_static_style_compute_value (gtkcssstaticstyle.c:237)
#   _gtk_css_lookup_resolve (gtkcsslookup.c:122)
#   gtk_css_static_style_new_compute (gtkcssstaticstyle.c:195)
JEPROF_IGNORES+=("call_once<\w+>")

# ----------------
# Make final regex
# ----------------

JEPROF_IGNORE_REGEX=$(IFS=\| ; echo "(${JEPROF_IGNORES[*]})")

