// staff.js — Staff Portal logic
// Depends on script.js being loaded first

(function () {

    // ── Auth guard ──────────────────────────────────────────────────────────
    var stored = sessionStorage.getItem('spUser');
    if (!stored) { window.location.href = 'index.html'; return; }
    var spUser = JSON.parse(stored);
    window.currentUser = spUser;

    // ── Init UI ─────────────────────────────────────────────────────────────
    document.getElementById('staffName').textContent = spUser.name;
    document.getElementById('staffAvatar').textContent = spUser.avatar || spUser.name.charAt(0).toUpperCase();

    document.getElementById('staffLogoutBtn').addEventListener('click', function () {
        sessionStorage.removeItem('spUser');
        window.location.href = 'index.html';
    });

    // ── Navigation ──────────────────────────────────────────────────────────
    window.switchStaffSection = function (sectionName) {
        document.querySelectorAll('#staffDashboard .admin-nav-btn').forEach(function (b) {
            b.classList.remove('active');
        });
        var activeBtn = document.querySelector('#staffDashboard [data-section="' + sectionName + '"]');
        if (activeBtn) {
            activeBtn.classList.add('active');
            var submenu = activeBtn.closest('.admin-submenu');
            if (submenu) {
                var parentBtn = submenu.previousElementSibling;
                if (parentBtn) parentBtn.classList.add('active');
            }
        }

        document.querySelectorAll('#staffDashboard .admin-section').forEach(function (s) {
            s.classList.remove('active');
        });
        var activeSection = document.getElementById(sectionName);
        if (activeSection) activeSection.classList.add('active');

        var titles = {
            'staff-overview':        'Dashboard',
            'staff-inventory':       'Stock Inventory',
            'staff-item-master':     'Item Master',
            'staff-inv-transactions':'Inventory Transactions',
            'staff-assets':          'Asset Management',
            'staff-asset-servicing': 'Asset Maintenance',
            'staff-issuance':        'Asset Issuance'
        };
        document.getElementById('staffSectionTitle').textContent = titles[sectionName] || 'Staff Portal';

        if (sectionName === 'staff-inventory')        { renderStaffInventoryList(); renderStaffItemMasterList(); }
        if (sectionName === 'staff-item-master')      { renderStaffItemMasterList(); }
        if (sectionName === 'staff-inv-transactions') { renderStaffInventoryTransactions(); }
        if (sectionName === 'staff-assets')           { renderStaffAssetsList(); }
        if (sectionName === 'staff-asset-servicing')  { renderStaffServicesList(); }
        if (sectionName === 'staff-issuance')         { renderStaffIssuancesList(); }
    };

    // ── Submenu toggles ─────────────────────────────────────────────────────
    window.toggleStaffInventorySubmenu = function (event) {
        event.stopPropagation();
        var submenu = document.getElementById('staffInventorySubmenu');
        var arrow   = document.getElementById('staffInvArrow');
        var opening = submenu.style.display === 'none';
        submenu.style.display = opening ? 'block' : 'none';
        if (arrow) arrow.textContent = opening ? '▲' : '▼';
        switchStaffSection('staff-item-master');
    };

    window.toggleStaffAssetSubmenu = function (event) {
        event.stopPropagation();
        var submenu = document.getElementById('staffAssetSubmenu');
        var arrow   = document.getElementById('staffAssetArrow');
        var opening = submenu.style.display === 'none';
        submenu.style.display = opening ? 'block' : 'none';
        if (arrow) arrow.textContent = opening ? '▲' : '▼';
        if (opening) switchStaffSection('staff-assets');
    };

    // Nav button clicks — handles both plain nav buttons and parent toggle buttons with data-section
    document.querySelectorAll('#staffDashboard .admin-nav-btn[data-section]').forEach(function (btn) {
        btn.addEventListener('click', function (e) {
            e.stopPropagation();
            switchStaffSection(this.getAttribute('data-section'));
        });
    });

    // ── Inventory (Stock) ───────────────────────────────────────────────────
    window.renderStaffInventoryList = window.renderStaffInventoryFull = function () {
        var list = document.getElementById('staffInventoryList');
        if (!list) return;

        var search = (document.getElementById('staffInventorySearchBar') || {value:''}).value.toLowerCase();
        var statusBadges = {
            low_stock:    '<span class="status-badge status-overdue">Low Stock</span>',
            in_stock:     '<span class="status-badge status-active">In Stock</span>',
            out_of_stock: '<span class="status-badge status-pending">Out of Stock</span>'
        };
        var cols = '100px 1.5fr 1fr 100px 90px 90px 110px 80px';
        var filtered = inventory.filter(function (item) {
            return item.itemNum.toLowerCase().includes(search)
                || item.itemName.toLowerCase().includes(search)
                || (item.commodityGroup || '').toLowerCase().includes(search);
        });

        list.innerHTML = filtered.length === 0
            ? '<div style="padding:2rem;text-align:center;color:#718096;">No items found.</div>'
            : filtered.map(function (item) {
                return '<div class="table-row" style="grid-template-columns:' + cols + ';">'
                    + '<div><strong>' + item.itemNum + '</strong></div>'
                    + '<div>' + item.itemName + '</div>'
                    + '<div>' + item.commodityGroup + '</div>'
                    + '<div style="text-align:center;">' + item.stock + ' <span style="font-size:0.75rem;color:#718096;">' + item.unit + '</span></div>'
                    + '<div style="text-align:center;">' + (item.minLevel != null ? item.minLevel : (item.reorderLevel != null ? item.reorderLevel : '-')) + '</div>'
                    + '<div style="text-align:center;">' + (item.maxLevel != null ? item.maxLevel : '-') + '</div>'
                    + '<div>' + (statusBadges[item.status] || '-') + '</div>'
                    + '<div><button class="btn-small btn-primary" onclick="viewItemDetails(\'' + item.itemNum + '\')" title="View">👁️</button></div>'
                    + '</div>';
            }).join('');

        var totalItems  = inventory.length;
        var lowStock    = inventory.filter(function (i) { return i.status === 'low_stock'; }).length;
        var inStock     = inventory.filter(function (i) { return i.status === 'in_stock'; }).length;
        var totalValue  = inventory.reduce(function (sum, i) { return sum + (i.stock * i.price); }, 0);
        var lastCount   = inventory.reduce(function (latest, i) {
            return i.lastPhysicalCount && (!latest || i.lastPhysicalCount > latest) ? i.lastPhysicalCount : latest;
        }, null);
        var s = function (id, val) { var el = document.getElementById(id); if (el) el.textContent = val; };
        s('staffTotalInventoryItems', totalItems);
        s('staffLowStockCount', lowStock);
        s('staffInStockCount', inStock);
        s('staffTotalInventoryValue', '₱' + totalValue.toLocaleString('en-PH'));
        s('staffLastPhysicalCountDate', lastCount ? new Date(lastCount).toLocaleDateString('en-US', { month:'short', day:'numeric' }) : '—');
    };

    // ── Item Master (view only) ─────────────────────────────────────────────
    window.renderStaffItemMasterList = function () {
        var list = document.getElementById('staffItemMasterList');
        if (!list) return;

        var _im     = (typeof itemMaster !== 'undefined' && Array.isArray(itemMaster)) ? itemMaster : (window.itemMaster || []);
        var search  = (document.getElementById('staffItemMasterSearch') || {value:''}).value.toLowerCase();
        var filtered = _im.filter(function (i) {
            return i.itemNum.toLowerCase().includes(search)
                || i.itemName.toLowerCase().includes(search)
                || (i.commodityGroup || '').toLowerCase().includes(search)
                || (i.description || '').toLowerCase().includes(search);
        });

        if (filtered.length === 0) {
            list.innerHTML = '<div style="padding:2rem;text-align:center;color:#718096;">No items found.</div>';
            return;
        }

        var typeBadge = function (t) {
            return t === 'Material'
                ? '<span style="background:#bee3f8;color:#2c5282;padding:0.2rem 0.6rem;border-radius:12px;font-size:0.8rem;font-weight:600;">Material</span>'
                : '<span style="background:#e9d8fd;color:#553c9a;padding:0.2rem 0.6rem;border-radius:12px;font-size:0.8rem;font-weight:600;">Service</span>';
        };

        list.innerHTML = filtered.map(function (i) {
            return '<div class="table-row" style="grid-template-columns:1fr 1fr 1.5fr 1fr 1fr 1fr 1fr;">'
                + '<div><strong>' + i.itemNum + '</strong></div>'
                + '<div>' + i.itemName + '</div>'
                + '<div style="font-size:0.85rem;color:#4a5568;">' + (i.description || '-') + '</div>'
                + '<div>' + (i.commodityGroup || '-') + '</div>'
                + '<div>' + (i.uom || '-') + '</div>'
                + '<div>' + typeBadge(i.itemType) + '</div>'
                + '<div>₱' + (i.cost || 0).toLocaleString('en-PH', { minimumFractionDigits: 2 }) + '</div>'
                + '</div>';
        }).join('');
    };

    // ── Inventory Transactions ──────────────────────────────────────────────
    window.renderStaffInventoryTransactions = function () {
        var search = (document.getElementById('staffTxnSearch') || {value:''}).value.toLowerCase().trim();
        var txns = [];

        var _deliveries = (typeof deliveryRecords !== 'undefined' && Array.isArray(deliveryRecords)) ? deliveryRecords : (window.deliveryRecords || []);
        _deliveries.forEach(function (d) {
            txns.push({ date: d.date, itemNum: d.itemNum, itemName: d.itemName, description: 'Delivery received', direction: 'in', qty: d.quantityReceived, by: d.receivedBy || '-' });
        });

        var _issuances = (typeof issuances !== 'undefined' && Array.isArray(issuances)) ? issuances : (window.issuances || []);
        _issuances.forEach(function (i) {
            txns.push({ date: i.date, itemNum: i.itemNum, itemName: i.description || i.itemNum, description: 'Issued to ' + (i.assetNum || '') + (i.assetDescription ? ' — ' + i.assetDescription : ''), direction: 'out', qty: i.quantity, by: i.createdBy || '-' });
        });

        txns.sort(function (a, b) { return new Date(b.date) - new Date(a.date); });

        var s = function (id, val) { var el = document.getElementById(id); if (el) el.textContent = val; };
        s('staffTxnTotal', txns.length);
        s('staffTxnIn',    txns.filter(function (t) { return t.direction === 'in'; }).length);
        s('staffTxnOut',   txns.filter(function (t) { return t.direction === 'out'; }).length);
        s('staffTxnItems', new Set(txns.map(function (t) { return t.itemNum; })).size);

        var list = document.getElementById('staffTxnList');
        if (!list) return;

        var filtered = search ? txns.filter(function (t) {
            return (t.itemNum || '').toLowerCase().includes(search)
                || (t.itemName || '').toLowerCase().includes(search)
                || (t.by || '').toLowerCase().includes(search);
        }) : txns;

        if (filtered.length === 0) {
            list.innerHTML = '<div class="table-row" style="text-align:center;color:#718096;padding:2rem;">No transactions found.</div>';
            return;
        }

        list.innerHTML = filtered.map(function (t) {
            var dirBadge  = t.direction === 'in'
                ? '<span style="background:#c6f6d5;color:#276749;padding:0.25rem 0.75rem;border-radius:20px;font-size:0.78rem;font-weight:700;letter-spacing:0.3px;">Receive</span>'
                : '<span style="background:#fed7d7;color:#c53030;padding:0.25rem 0.75rem;border-radius:20px;font-size:0.78rem;font-weight:700;letter-spacing:0.3px;">Issue</span>';
            var qtyColor  = t.direction === 'in' ? '#276749' : '#c53030';
            var qtySign   = t.direction === 'in' ? '+' : '-';
            var dateStr   = new Date(t.date).toLocaleDateString('en-US', { month:'short', day:'numeric', year:'numeric' });
            return '<div class="table-row" style="grid-template-columns:120px 1fr 1.5fr 80px 80px 100px;">'
                + '<div style="font-size:0.85rem;color:#4a5568;">' + dateStr + '</div>'
                + '<div><strong style="font-size:0.9rem;">' + t.itemNum + '</strong><br><span style="font-size:0.8rem;color:#718096;">' + t.itemName + '</span></div>'
                + '<div style="font-size:0.85rem;color:#4a5568;">' + t.description + '</div>'
                + '<div>' + dirBadge + '</div>'
                + '<div style="font-weight:800;color:' + qtyColor + ';font-size:1rem;">' + qtySign + t.qty + '</div>'
                + '<div style="font-size:0.85rem;color:#4a5568;">' + (t.by && t.by !== '-' ? t.by : '<span style="color:#a0aec0;">—</span>') + '</div>'
                + '</div>';
        }).join('');
    };

    // ── Assets List ─────────────────────────────────────────────────────────
    window.renderStaffAssetsList = function () {
        var list = document.getElementById('staffAssetsList');
        if (!list) return;
        if (assets.length === 0) {
            list.innerHTML = '<div class="table-row" style="text-align:center;color:#718096;padding:2rem;">No assets found.</div>';
            return;
        }
        var today = new Date(); today.setHours(0,0,0,0);
        function getStatusBadge(asset) {
            // Auto-reset completed → active after 1 day
            if (asset.status === 'completed' && asset.completedAt) {
                var completedDate = new Date(asset.completedAt);
                completedDate.setHours(0,0,0,0);
                if (Math.ceil((today - completedDate) / 86400000) >= 1) {
                    asset.status = 'active';
                    asset.completedAt = null;
                }
            }
            if (asset.status === 'inactive') return '<span class="status-badge status-completed">Inactive</span>';
            if (asset.status === 'maintenance') return '<span class="status-badge" style="background:#bee3f8;color:#1a365d;border:1px solid #90cdf4;display:inline-flex;align-items:center;gap:0.35rem;padding:0.35rem 0.85rem;border-radius:20px;font-size:0.78rem;font-weight:700;white-space:nowrap;"><span style="width:7px;height:7px;border-radius:50%;background:#3182ce;flex-shrink:0;display:inline-block;"></span>Under Maintenance</span>';
            if (asset.status === 'completed') return '<span class="status-badge status-completed">Completed</span>';
            if (asset.nextPMSDue) {
                var due = new Date(asset.nextPMSDue); due.setHours(0,0,0,0);
                var diff = Math.ceil((due - today) / 86400000);
                if (diff < 0)  return '<span class="status-badge status-overdue">PMS Overdue</span>';
                if (diff <= 14) return '<span class="status-badge status-pending">PMS Due Soon</span>';
            }
            return '<span class="status-badge status-active">Active</span>';
        }
        var typeLabels = { car:'Car', truck:'Truck' };
        list.innerHTML = assets.map(function (asset) {
            var typeLabel = typeLabels[asset.type] || asset.type || '-';
            var lastSvc   = asset.lastServiceDate ? new Date(asset.lastServiceDate).toLocaleDateString('en-US', { month:'short', day:'numeric', year:'numeric' }) : '-';
            var nextPMS   = asset.nextPMSDue       ? new Date(asset.nextPMSDue).toLocaleDateString('en-US',       { month:'short', day:'numeric', year:'numeric' }) : '-';
            return '<div class="table-row" style="grid-template-columns:1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 120px;">'
                + '<div><strong>' + asset.assetNum + '</strong></div>'
                + '<div>' + asset.plateNumber + '</div>'
                + '<div>' + asset.icon + ' ' + typeLabel + '</div>'
                + '<div>' + asset.owner + '</div>'
                + '<div>' + (asset.odometer ? asset.odometer.toLocaleString() + ' km' : '-') + '</div>'
                + '<div>' + lastSvc + '</div>'
                + '<div>' + nextPMS + '</div>'
                + '<div>' + getStatusBadge(asset) + '</div>'
                + '<div style="display:flex;gap:0.4rem;">'
                + '<button class="btn-small btn-primary" onclick="viewAssetDetails(\'' + asset.assetNum + '\')" title="View">👁️</button>'
                + '<button class="btn-small btn-secondary" onclick="editAsset(\'' + asset.assetNum + '\')" title="Edit">✏️</button>'
                + '</div></div>';
        }).join('');
    };

    // ── Asset Maintenance ───────────────────────────────────────────────────
    window.renderStaffServicesList = function () {
        var list = document.getElementById('staffServicesList');
        if (!list) return;
        var total     = serviceTransactions.length;
        var ongoing   = serviceTransactions.filter(function (s) { return s.status === 'ongoing'; }).length;
        var completed = serviceTransactions.filter(function (s) { return s.status === 'complete'; }).length;
        var pending   = serviceTransactions.filter(function (s) { return s.status === 'pending'; }).length;
        var set = function (id, val) { var el = document.getElementById(id); if (el) el.textContent = val; };
        set('staffTotalServices',    total);
        set('staffOngoingServices',  ongoing);
        set('staffCompletedServices',completed);
        set('staffPendingServices',  pending);
        if (total === 0) {
            list.innerHTML = '<div class="table-row" style="text-align:center;color:#718096;padding:2rem;">No service transactions found.</div>';
            return;
        }
        var statusBadges = {
            pending:  '<span style="background:#fefcbf;color:#744210;padding:0.2rem 0.6rem;border-radius:12px;font-size:0.8rem;font-weight:600;">Pending</span>',
            ongoing:  '<span style="background:#bee3f8;color:#1a365d;border:1px solid #90cdf4;display:inline-flex;align-items:center;gap:0.35rem;padding:0.35rem 0.75rem;border-radius:20px;font-size:0.78rem;font-weight:700;"><span style="width:7px;height:7px;border-radius:50%;background:#3182ce;flex-shrink:0;display:inline-block;"></span>Ongoing</span>',
            complete: '<span style="background:#e2e8f0;color:#2d3748;border:1px solid #cbd5e0;display:inline-flex;align-items:center;gap:0.35rem;padding:0.35rem 0.75rem;border-radius:20px;font-size:0.78rem;font-weight:700;"><span style="width:7px;height:7px;border-radius:50%;background:#718096;flex-shrink:0;display:inline-block;"></span>Completed</span>'
        };
        list.innerHTML = serviceTransactions.map(function (svc) {
            var date   = svc.dateServiced ? new Date(svc.dateServiced).toLocaleDateString('en-US', { month:'short', day:'numeric', year:'numeric' }) : '—';
            var badge  = statusBadges[svc.status] || '<span class="status-badge">' + svc.status + '</span>';
            var btns   = '<button class="btn-small btn-primary" onclick="viewServiceDetails(\'' + svc.serviceId + '\')" title="View">👁️</button>'
                       + ' <button class="btn-small btn-secondary" onclick="editService(\'' + svc.serviceId + '\')" title="Edit">✏️</button>';
            if (svc.status === 'ongoing') btns += ' <button class="btn-small btn-success" onclick="completeService(\'' + svc.serviceId + '\')" title="Mark Complete">🏁</button>';
            return '<div class="table-row" style="grid-template-columns:1fr 1fr 1.5fr 1fr 1fr 1fr 160px;">'
                + '<div>' + date + '</div>'
                + '<div><strong>' + svc.assetNum + '</strong></div>'
                + '<div style="font-size:0.85rem;color:#4a5568;">' + (svc.assetDescription || '-') + '</div>'
                + '<div>' + (svc.mechanicName || '-') + '</div>'
                + '<div><strong>₱' + parseFloat(svc.totalCost).toLocaleString('en-PH', { minimumFractionDigits:2 }) + '</strong></div>'
                + '<div>' + badge + '</div>'
                + '<div style="display:flex;gap:0.3rem;flex-wrap:wrap;">' + btns + '</div>'
                + '</div>';
        }).join('');
    };

    // ── Issuances ───────────────────────────────────────────────────────────
    window.renderStaffIssuancesList = function () {
        var list = document.getElementById('staffIssuancesList');
        if (!list) return;
        var set = function (id, val) { var el = document.getElementById(id); if (el) el.textContent = val; };
        set('staffTotalIssuances',   issuances.length);
        set('staffTotalServicesIss', issuances.filter(function (i) { return i.itemType === 'service'; }).length);
        set('staffTotalMaterials',   issuances.filter(function (i) { return i.itemType === 'material'; }).length);
        if (issuances.length === 0) {
            list.innerHTML = '<div class="table-row" style="text-align:center;color:#718096;padding:2rem;min-width:1400px;">No issuance records found.</div>';
            return;
        }
        list.innerHTML = issuances.map(function (iss) {
            var date     = iss.date ? new Date(iss.date).toLocaleDateString('en-US', { month:'short', day:'numeric', year:'numeric' }) : '—';
            var subtotal = (iss.quantity || 0) * (iss.unitCost || 0);
            return '<div class="table-row" style="min-width:1400px;grid-template-columns:100px 120px 120px 200px 100px 140px 80px 90px 110px 110px 130px;">'
                + '<div>' + date + '</div>'
                + '<div>' + (iss.assetNum || '—') + '</div>'
                + '<div>' + (iss.itemNum || '—') + '</div>'
                + '<div>' + (iss.description || '—') + '</div>'
                + '<div>' + (iss.itemType || '—') + '</div>'
                + '<div>' + (iss.commodityGroup || '—') + '</div>'
                + '<div>' + (iss.uom || '—') + '</div>'
                + '<div>' + (iss.quantity || 0) + '</div>'
                + '<div>₱' + (iss.unitCost || 0).toLocaleString() + '</div>'
                + '<div>₱' + subtotal.toLocaleString() + '</div>'
                + '<div><button class="btn-small btn-primary" onclick="viewIssuanceDetails(' + iss.id + ')">👁️ View</button></div>'
                + '</div>';
        }).join('');
    };

    // ── Boot: show dashboard ────────────────────────────────────────────────
    switchStaffSection('staff-overview');

})();
