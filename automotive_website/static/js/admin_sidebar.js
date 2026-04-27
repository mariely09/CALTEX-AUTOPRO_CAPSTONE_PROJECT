// Page → URL mapping for navigation
const PAGE_URLS = {
    'overview':                 'admin_dashboard.html',
    'item-master':              'admin_inventory_itemaster.html',
    'inventory':                'admin_inventory_stock.html',
    'inventory-transactions':   'admin_dashboard.html#inventory-transactions',
    'assets':                   'admin_vehicle_list.html',
    'asset-servicing':          'admin_vehicle_maintenance.html',
    'issuance':                 'admin_dashboard.html#issuance',
    'dss':                      'admin_dss.html',
    'dss-pms':                  'admin_dss.html#dss-pms',
    'users':                    'admin_users.html',
    'smart-reports':            'admin_smart_reports.html',
    'domains':                  'admin_domain_management.html',
};

function navigateTo(section) {
    const url = PAGE_URLS[section];
    if (!url) return;

    // If we're navigating to a hash on the same page, update data-page and active state in place
    const currentPage = window.location.pathname.split('/').pop();
    const [targetFile, targetHash] = url.split('#');

    if (currentPage === targetFile && targetHash) {
        document.body.setAttribute('data-page', section);
        initSidebarActive();
        window.location.hash = targetHash;
        if (typeof switchDSSSection === 'function') switchDSSSection(section);
    } else if (currentPage === targetFile && !targetHash) {
        document.body.setAttribute('data-page', section);
        initSidebarActive();
        history.pushState(null, '', window.location.pathname);
        if (typeof switchDSSSection === 'function') switchDSSSection(section);
    } else {
        window.location.href = url;
    }
}

function toggleAdminSidebar() {
    const sidebar = document.getElementById('adminSidebar');
    const overlay = document.getElementById('adminSidebarOverlay');
    if (!sidebar) return;
    const isOpen = sidebar.classList.toggle('admin-sidebar-open');
    if (overlay) overlay.classList.toggle('active', isOpen);
}

function initSidebarActive() {
    const page = document.body.getAttribute('data-page') || 'overview';

    document.querySelectorAll('.admin-nav-btn[data-section]').forEach(btn => {
        btn.classList.toggle('active', btn.getAttribute('data-section') === page);
    });
}

function bindHeaderControls() {
    const menuBtn = document.getElementById('adminMenuBtn');
    if (menuBtn) menuBtn.addEventListener('click', toggleAdminSidebar);

    const overlay = document.getElementById('adminSidebarOverlay');
    if (overlay) overlay.addEventListener('click', toggleAdminSidebar);

    if (typeof firebase !== 'undefined') {
        firebase.auth().onAuthStateChanged(user => {
            if (user) {
                const avatar = document.getElementById('adminHeaderAvatar');
                if (avatar) {
                    const name = user.displayName || user.email || 'AD';
                    avatar.textContent = name.slice(0, 2).toUpperCase();
                }
            }
        });
    }
}

// Load header then sidebar, bind controls after both are ready
(function init() {
    const headerContainer  = document.getElementById('headerContainer');
    const sidebarContainer = document.getElementById('sidebarContainer');

    const headerPromise = headerContainer
        ? fetch('admin_header.html').then(r => r.text()).then(html => { headerContainer.innerHTML = html; })
        : Promise.resolve();

    const sidebarPromise = sidebarContainer
        ? fetch('admin_sidebar.html').then(r => r.text()).then(html => { sidebarContainer.innerHTML = html; initSidebarActive(); })
        : Promise.resolve();

    Promise.all([headerPromise, sidebarPromise]).then(bindHeaderControls);
})();
