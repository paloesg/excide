"use strict";

// Initialization
KTUtil.ready(function() {
    ////////////////////////////////////////////////////
    // Layout Base Partials(mandatory for core layout)//
    ////////////////////////////////////////////////////

    // Init Desktop & Mobile Headers
    KTLayoutHeader.init('kt_header', 'kt_header_mobile');

    // Init Header Menu
    KTLayoutHeaderMenu.init('kt_header_menu', 'kt_header_bottom');

    // Init Header Topbar For Mobile Mode
    KTLayoutHeaderTopbar.init('kt_header_topbar');

    // Init Aside
    KTLayoutAside.init('kt_aside');

    // Init Aside Menu
    KTLayoutAsideMenu.init('kt_aside_menu');

    // Init Subheader
    KTLayoutSubheader.init('kt_subheader');

    // Init Content
    KTLayoutContent.init('kt_content');

    // Init Footer
    KTLayoutFooter.init('kt_footer');

    //////////////////////////////////////////////
    // Layout Extended Partials(optional to use)//
    //////////////////////////////////////////////


    // Init Scrolltop
    KTLayoutScrolltop.init('kt_scrolltop');

    // Init Sticky Card
    KTLayoutStickyCard.init('kt_page_sticky_card');

    // Init Stretched Card
    KTLayoutStretchedCard.init('kt_page_stretched_card');

    // Init Code Highlighter & Preview Blocks(used to demonstrate the theme features)
	KTLayoutExamples.init();

    // Init Demo Selection Panel
	KTLayoutDemoPanel.init('kt_demo_panel');

    // Init Chat App(quick modal chat)
    KTLayoutChat.init();

    // Init Quick Actions Offcanvas Panel
    KTLayoutQuickActions.init('kt_quick_actions');

    // Init Quick Notifications Offcanvas Panel
    KTLayoutQuickNotifications.init('kt_quick_notifications');

    // Init Quick Offcanvas Panel
    KTLayoutQuickPanel.init('kt_quick_panel');

    // Init Quick Search Panel
    KTLayoutQuickSearch.init('kt_quick_search');

    // Init Quick User Panel
    KTLayoutQuickUser.init('kt_quick_user');

    // Init Search Dropdown For Desktop Mode
    KTLayoutSearchInline().init('kt_quick_search_inline');
});
