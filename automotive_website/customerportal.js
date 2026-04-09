// customerportal.js — Customer Portal logic
// Depends on script.js being loaded first (provides: assets, escapeHtml, etc.)

(function () {

    // ── Auth guard ──────────────────────────────────────────────────────────
    var stored = sessionStorage.getItem('cpUser');
    if (!stored) {
        window.location.href = 'index.html';
        return;
    }
    var cpUser = JSON.parse(stored);
    window.currentUser = cpUser;

    // ── Init UI ─────────────────────────────────────────────────────────────
    document.getElementById('customerName').textContent = cpUser.name;
    document.getElementById('customerAvatar').textContent = cpUser.avatar || cpUser.name.charAt(0).toUpperCase();

    document.getElementById('customerLogoutBtn').addEventListener('click', function () {
        sessionStorage.removeItem('cpUser');
        window.location.href = 'index.html';
    });

    document.querySelectorAll('#customerDashboard .admin-nav-btn').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var section = this.getAttribute('data-section');
            if (section) switchCustomerSection(section);
        });
    });

    renderCustomerVehicles();

    // ── Navigation ──────────────────────────────────────────────────────────
    window.switchCustomerSection = function (sectionName) {
        document.querySelectorAll('#customerDashboard .admin-nav-btn').forEach(function (b) {
            b.classList.remove('active');
        });
        var activeBtn = document.querySelector('#customerDashboard [data-section="' + sectionName + '"]');
        if (activeBtn) activeBtn.classList.add('active');

        document.querySelectorAll('#customerDashboard .admin-section').forEach(function (s) {
            s.classList.remove('active');
        });
        var activeSection = document.getElementById(sectionName);
        if (activeSection) activeSection.classList.add('active');

        var titles = {
            'customer-vehicles': 'My Vehicles',
            'customer-reminders': 'Smart Reports'
        };
        document.getElementById('customerSectionTitle').textContent = titles[sectionName] || 'Customer Portal';

        if (sectionName === 'customer-reminders') updateCustomerSmartStats();
    };

    // ── Vehicle rendering ───────────────────────────────────────────────────
    window.renderCustomerVehicles = function () {
        var ownerName = cpUser.name;
        var myAssets = assets.filter(function (a) { return a.owner === ownerName; });

        var today = new Date();
        today.setHours(0, 0, 0, 0);

        var total = myAssets.length;
        var underMaint = myAssets.filter(function (a) { return a.status === 'maintenance'; }).length;
        var pmsDueSoon = myAssets.filter(function (a) {
            if (!a.nextPMSDue || a.status === 'maintenance' || a.status === 'inactive') return false;
            var due = new Date(a.nextPMSDue); due.setHours(0, 0, 0, 0);
            var diff = Math.ceil((due - today) / 86400000);
            return diff >= 0 && diff <= 14;
        }).length;
        var pmsOverdue = myAssets.filter(function (a) {
            if (!a.nextPMSDue || a.status === 'maintenance' || a.status === 'inactive') return false;
            var due = new Date(a.nextPMSDue); due.setHours(0, 0, 0, 0);
            return due < today;
        }).length;

        // Stats
        var statsEl = document.getElementById('customerVehicleStats');
        if (statsEl) {
            statsEl.innerHTML =
                '<div style="background:linear-gradient(135deg,#E31E24 0%,#C41E3A 100%);padding:1.75rem;border-radius:16px;color:white;box-shadow:0 8px 24px rgba(227,30,36,0.3);position:relative;overflow:hidden;"><div style="position:absolute;top:-15px;right:-15px;font-size:5rem;opacity:0.1;">🚛</div><div style="font-size:0.85rem;opacity:0.9;margin-bottom:0.5rem;font-weight:500;">Total Vehicles</div><div style="font-size:2.5rem;font-weight:800;">' + total + '</div><div style="font-size:0.8rem;opacity:0.85;margin-top:0.3rem;">' + ownerName + '\u2019s fleet</div></div>' +
                '<div style="background:linear-gradient(135deg,#3182ce 0%,#2c5282 100%);padding:1.75rem;border-radius:16px;color:white;box-shadow:0 8px 24px rgba(49,130,206,0.3);position:relative;overflow:hidden;"><div style="position:absolute;top:-15px;right:-15px;font-size:5rem;opacity:0.1;">🔧</div><div style="font-size:0.85rem;opacity:0.9;margin-bottom:0.5rem;font-weight:500;">Under Maintenance</div><div style="font-size:2.5rem;font-weight:800;">' + underMaint + '</div><div style="font-size:0.8rem;opacity:0.85;margin-top:0.3rem;">Currently being serviced</div></div>' +
                '<div style="background:linear-gradient(135deg,#d69e2e 0%,#b7791f 100%);padding:1.75rem;border-radius:16px;color:white;box-shadow:0 8px 24px rgba(214,158,46,0.3);position:relative;overflow:hidden;"><div style="position:absolute;top:-15px;right:-15px;font-size:5rem;opacity:0.1;">📅</div><div style="font-size:0.85rem;opacity:0.9;margin-bottom:0.5rem;font-weight:500;">PMS Due Soon</div><div style="font-size:2.5rem;font-weight:800;">' + pmsDueSoon + '</div><div style="font-size:0.8rem;opacity:0.85;margin-top:0.3rem;">Within 14 days</div></div>' +
                '<div style="background:linear-gradient(135deg,#e53e3e 0%,#c53030 100%);padding:1.75rem;border-radius:16px;color:white;box-shadow:0 8px 24px rgba(229,62,62,0.3);position:relative;overflow:hidden;"><div style="position:absolute;top:-15px;right:-15px;font-size:5rem;opacity:0.1;">⚠️</div><div style="font-size:0.85rem;opacity:0.9;margin-bottom:0.5rem;font-weight:500;">PMS Overdue</div><div style="font-size:2.5rem;font-weight:800;">' + pmsOverdue + '</div><div style="font-size:0.8rem;opacity:0.85;margin-top:0.3rem;">Needs immediate attention</div></div>';
        }

        var listEl = document.getElementById('customerVehiclesList');
        if (!listEl) return;

        if (myAssets.length === 0) {
            listEl.innerHTML = '<div style="color:#718096;padding:2rem;text-align:center;">No vehicles found for this account.</div>';
            return;
        }

        function getStatusInfo(asset) {
            if (asset.status === 'maintenance') return { label: '🔵 Under Maintenance', color: 'rgba(255,255,255,0.3)' };
            if (asset.status === 'inactive') return { label: '⚫ Inactive', color: 'rgba(255,255,255,0.2)' };
            if (asset.nextPMSDue) {
                var due = new Date(asset.nextPMSDue); due.setHours(0, 0, 0, 0);
                var diff = Math.ceil((due - today) / 86400000);
                if (diff < 0) return { label: '🔴 PMS Overdue', color: 'rgba(255,100,100,0.4)' };
                if (diff <= 14) return { label: '🟡 PMS Due Soon', color: 'rgba(255,200,50,0.35)' };
            }
            return { label: '✅ Active', color: 'rgba(255,255,255,0.25)' };
        }

        listEl.innerHTML = myAssets.map(function (asset) {
            var si = getStatusInfo(asset);
            var lastSvc = asset.lastServiceDate
                ? new Date(asset.lastServiceDate).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
                : '—';
            var nextPMS = asset.nextPMSDue
                ? new Date(asset.nextPMSDue).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
                : '—';
            var odo = asset.odometer ? asset.odometer.toLocaleString() + ' km' : '—';

            var pmsColor = '#2c5282', pmsBg = 'linear-gradient(135deg,#ebf8ff 0%,#bee3f8 100%)', pmsBorder = '#4299e1';
            if (asset.nextPMSDue) {
                var due2 = new Date(asset.nextPMSDue); due2.setHours(0, 0, 0, 0);
                var diff2 = Math.ceil((due2 - today) / 86400000);
                if (diff2 < 0) { pmsColor = '#742a2a'; pmsBg = 'linear-gradient(135deg,#fff5f5 0%,#fed7d7 100%)'; pmsBorder = '#f56565'; }
                else if (diff2 <= 14) { pmsColor = '#7c2d12'; pmsBg = 'linear-gradient(135deg,#fff5e6 0%,#feebc8 100%)'; pmsBorder = '#ed8936'; }
            }

            return '<div style="background:white;border-radius:20px;overflow:hidden;box-shadow:0 8px 30px rgba(0,0,0,0.1);border:1px solid #e2e8f0;transition:all 0.3s ease;" onmouseover="this.style.transform=\'translateY(-4px)\';this.style.boxShadow=\'0 16px 40px rgba(0,0,0,0.15)\';" onmouseout="this.style.transform=\'translateY(0)\';this.style.boxShadow=\'0 8px 30px rgba(0,0,0,0.1)\';">'
                + '<div style="background:linear-gradient(135deg,#E31E24 0%,#C41E3A 100%);padding:1.75rem;color:white;position:relative;overflow:hidden;">'
                + '<div style="position:absolute;top:-25px;right:-25px;font-size:9rem;opacity:0.08;">' + asset.icon + '</div>'
                + '<div style="display:flex;justify-content:space-between;align-items:start;position:relative;z-index:1;">'
                + '<div style="display:flex;align-items:center;gap:1rem;">'
                + '<div style="background:rgba(255,255,255,0.2);width:54px;height:54px;border-radius:14px;display:flex;align-items:center;justify-content:center;font-size:1.75rem;backdrop-filter:blur(10px);">' + asset.icon + '</div>'
                + '<div><div style="font-size:1.2rem;font-weight:800;">' + asset.assetDescription + '</div>'
                + '<div style="font-size:0.95rem;opacity:0.9;margin-top:0.15rem;">' + asset.plateNumber + ' &nbsp;·&nbsp; ' + asset.assetNum + '</div></div></div>'
                + '<span style="background:' + si.color + ';padding:0.4rem 0.9rem;border-radius:20px;font-size:0.78rem;font-weight:700;backdrop-filter:blur(10px);border:1px solid rgba(255,255,255,0.2);white-space:nowrap;">' + si.label + '</span>'
                + '</div></div>'
                + '<div style="padding:1.5rem;">'
                + '<div style="display:grid;grid-template-columns:1fr 1fr;gap:1rem;margin-bottom:1.5rem;">'
                + '<div style="background:linear-gradient(135deg,#f7fafc 0%,#edf2f7 100%);padding:1rem;border-radius:12px;border-left:4px solid #E31E24;"><div style="font-size:0.75rem;color:#718096;font-weight:600;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:0.3rem;">📏 Odometer</div><div style="font-size:1.2rem;font-weight:800;color:#1a202c;">' + odo + '</div></div>'
                + '<div style="background:linear-gradient(135deg,#f0fff4 0%,#c6f6d5 100%);padding:1rem;border-radius:12px;border-left:4px solid #48bb78;"><div style="font-size:0.75rem;color:#22543d;font-weight:600;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:0.3rem;">✅ Last Service</div><div style="font-size:1rem;font-weight:700;color:#22543d;">' + lastSvc + '</div></div>'
                + '<div style="background:' + pmsBg + ';padding:1rem;border-radius:12px;border-left:4px solid ' + pmsBorder + ';"><div style="font-size:0.75rem;color:' + pmsColor + ';font-weight:600;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:0.3rem;">📅 Next PMS</div><div style="font-size:1rem;font-weight:700;color:' + pmsColor + ';">' + nextPMS + '</div></div>'
                + '</div>'
                + '<button class="btn-primary" style="width:100%;padding:0.9rem;font-weight:700;border-radius:12px;font-size:0.95rem;justify-content:center;" onclick="viewVehicleHistory(\'' + asset.plateNumber + '\')">📋 View Maintenance History</button>'
                + '</div></div>';
        }).join('');
    };

    // ── Smart Reports stats ─────────────────────────────────────────────────
    window.updateCustomerSmartStats = function () {
        var myAssets = assets.filter(function (a) { return a.owner === cpUser.name; });
        var today = new Date(); today.setHours(0, 0, 0, 0);

        var overdue = myAssets.filter(function (a) {
            if (!a.nextPMSDue || a.status === 'maintenance' || a.status === 'inactive') return false;
            var due = new Date(a.nextPMSDue); due.setHours(0, 0, 0, 0);
            return due < today;
        }).length;
        var dueSoon = myAssets.filter(function (a) {
            if (!a.nextPMSDue || a.status === 'maintenance' || a.status === 'inactive') return false;
            var diff = Math.ceil((new Date(a.nextPMSDue) - today) / 86400000);
            return diff >= 0 && diff <= 14;
        }).length;
        var maint = myAssets.filter(function (a) { return a.status === 'maintenance'; }).length;

        var s = function (id) { return document.getElementById(id); };
        if (s('csrStatAssets')) s('csrStatAssets').textContent = myAssets.length;
        if (s('csrStatOverdue')) s('csrStatOverdue').textContent = overdue;
        if (s('csrStatDueSoon')) s('csrStatDueSoon').textContent = dueSoon;
        if (s('csrStatMaint')) s('csrStatMaint').textContent = maint;
    };

    // ── Smart Chat ──────────────────────────────────────────────────────────
    window.clearCustomerSmartChat = function () {
        var messages = document.getElementById('csrChatMessages');
        if (!messages) return;
        messages.innerHTML = '<div class="sr-welcome-bubble"><div class="sr-avatar-ai">🤖</div><div class="sr-bubble-ai"><div style="font-weight:700;margin-bottom:0.4rem;font-size:0.95rem;">Hello! I\'m your Smart Reports assistant. 👋</div><div style="color:#4a5568;font-size:0.88rem;line-height:1.6;margin-bottom:1rem;">Ask me anything about your vehicles — PMS status, maintenance history, and more.</div><div class="sr-welcome-chips"><button class="sr-suggest-chip" onclick="runCustomerSmartQuery(\'Show all my vehicles\')">🚛 All my vehicles</button><button class="sr-suggest-chip" onclick="runCustomerSmartQuery(\'Which of my assets are under maintenance?\')">🔵 Under maintenance</button><button class="sr-suggest-chip" onclick="runCustomerSmartQuery(\'Which of my assets have PMS overdue?\')">⚠️ PMS overdue</button><button class="sr-suggest-chip" onclick="runCustomerSmartQuery(\'Which of my assets have PMS due soon?\')">📅 PMS due soon</button><button class="sr-suggest-chip" onclick="runCustomerSmartQuery(\'Show maintenance history of my assets\')">📋 Maintenance history</button></div></div></div>';
    };

    window.runCustomerSmartQuery = function (queryText) {
        var input = document.getElementById('customerSmartQueryInput');
        var query = queryText || (input ? input.value.trim() : '');
        if (!query) return;
        if (input) { input.value = ''; input.style.height = 'auto'; }

        var messages = document.getElementById('csrChatMessages');
        if (!messages) return;

        // User bubble
        messages.innerHTML += '<div class="sr-msg-row sr-msg-user"><div class="sr-bubble-user">' + query + '</div><div class="sr-avatar-user">👤</div></div>';

        // Typing indicator
        var typingId = 'csr-typing-' + Date.now();
        messages.innerHTML += '<div class="sr-msg-row" id="' + typingId + '"><div class="sr-avatar-ai">🤖</div><div class="sr-bubble-ai sr-typing"><span></span><span></span><span></span></div></div>';
        messages.scrollTop = messages.scrollHeight;

        setTimeout(function () {
            var typingEl = document.getElementById(typingId);
            if (typingEl) typingEl.remove();

            var response = buildCustomerSmartResponse(query.toLowerCase(), cpUser.name);
            messages.innerHTML += '<div class="sr-msg-row"><div class="sr-avatar-ai">🤖</div><div class="sr-bubble-ai">' + response + '</div></div>';
            messages.scrollTop = messages.scrollHeight;
        }, 700);
    };

    function buildCustomerSmartResponse(q, ownerName) {
        var myAssets = assets.filter(function (a) { return a.owner === ownerName; });
        var today = new Date(); today.setHours(0, 0, 0, 0);

        function fmtDate(d) {
            return d ? new Date(d).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }) : '—';
        }

        function assetRow(a) {
            return '<div style="background:#f8fafc;border-radius:10px;padding:0.85rem 1rem;margin-bottom:0.5rem;border-left:4px solid #E31E24;">'
                + '<div style="font-weight:700;color:#1a202c;">' + a.icon + ' ' + a.assetDescription + '</div>'
                + '<div style="font-size:0.82rem;color:#718096;margin-top:0.2rem;">' + a.plateNumber + ' · ' + a.assetNum + '</div>'
                + '</div>';
        }

        // All vehicles
        if (q.includes('all') || q.includes('show') && q.includes('vehicle')) {
            if (myAssets.length === 0) return 'You have no registered vehicles.';
            return '<div style="font-weight:700;margin-bottom:0.75rem;">You have <span style="color:#E31E24;">' + myAssets.length + '</span> registered vehicle(s):</div>'
                + myAssets.map(assetRow).join('');
        }

        // Under maintenance
        if (q.includes('maintenance')) {
            var maint = myAssets.filter(function (a) { return a.status === 'maintenance'; });
            if (maint.length === 0) return '✅ None of your vehicles are currently under maintenance.';
            return '<div style="font-weight:700;margin-bottom:0.75rem;"><span style="color:#3182ce;">' + maint.length + '</span> vehicle(s) under maintenance:</div>'
                + maint.map(assetRow).join('');
        }

        // PMS overdue
        if (q.includes('overdue')) {
            var od = myAssets.filter(function (a) {
                if (!a.nextPMSDue || a.status === 'maintenance' || a.status === 'inactive') return false;
                var due = new Date(a.nextPMSDue); due.setHours(0, 0, 0, 0);
                return due < today;
            });
            if (od.length === 0) return '✅ No PMS overdue vehicles. Great job keeping up with maintenance!';
            return '<div style="font-weight:700;margin-bottom:0.75rem;color:#e53e3e;">⚠️ ' + od.length + ' vehicle(s) with PMS overdue:</div>'
                + od.map(function (a) {
                    return '<div style="background:#fff5f5;border-radius:10px;padding:0.85rem 1rem;margin-bottom:0.5rem;border-left:4px solid #f56565;">'
                        + '<div style="font-weight:700;color:#1a202c;">' + a.icon + ' ' + a.assetDescription + '</div>'
                        + '<div style="font-size:0.82rem;color:#742a2a;margin-top:0.2rem;">PMS was due: ' + fmtDate(a.nextPMSDue) + '</div>'
                        + '</div>';
                }).join('');
        }

        // PMS due soon
        if (q.includes('due soon') || q.includes('due')) {
            var ds = myAssets.filter(function (a) {
                if (!a.nextPMSDue || a.status === 'maintenance' || a.status === 'inactive') return false;
                var diff = Math.ceil((new Date(a.nextPMSDue) - today) / 86400000);
                return diff >= 0 && diff <= 14;
            });
            if (ds.length === 0) return '✅ No vehicles with PMS due in the next 14 days.';
            return '<div style="font-weight:700;margin-bottom:0.75rem;color:#d69e2e;">📅 ' + ds.length + ' vehicle(s) with PMS due soon:</div>'
                + ds.map(function (a) {
                    var diff = Math.ceil((new Date(a.nextPMSDue) - today) / 86400000);
                    return '<div style="background:#fffbeb;border-radius:10px;padding:0.85rem 1rem;margin-bottom:0.5rem;border-left:4px solid #ed8936;">'
                        + '<div style="font-weight:700;color:#1a202c;">' + a.icon + ' ' + a.assetDescription + '</div>'
                        + '<div style="font-size:0.82rem;color:#7c2d12;margin-top:0.2rem;">Due: ' + fmtDate(a.nextPMSDue) + ' (in ' + diff + ' day' + (diff !== 1 ? 's' : '') + ')</div>'
                        + '</div>';
                }).join('');
        }

        // Maintenance history
        if (q.includes('history')) {
            if (myAssets.length === 0) return 'No vehicles found.';
            return '<div style="font-weight:700;margin-bottom:0.75rem;">📋 Maintenance history for your vehicles:</div>'
                + myAssets.map(function (a) {
                    var rows = a.maintenanceHistory.length === 0
                        ? '<div style="color:#718096;font-size:0.82rem;padding:0.5rem 0;">No history yet.</div>'
                        : a.maintenanceHistory.slice(0, 3).map(function (r) {
                            return '<div style="font-size:0.82rem;color:#4a5568;padding:0.3rem 0;border-bottom:1px solid #e2e8f0;">'
                                + fmtDate(r.date) + ' — <strong>' + r.service + '</strong> (₱' + r.cost.toLocaleString() + ')</div>';
                        }).join('');
                    return '<div style="background:#f8fafc;border-radius:10px;padding:0.85rem 1rem;margin-bottom:0.75rem;border-left:4px solid #E31E24;">'
                        + '<div style="font-weight:700;color:#1a202c;margin-bottom:0.5rem;">' + a.icon + ' ' + a.assetDescription + ' — ' + a.plateNumber + '</div>'
                        + rows + '</div>';
                }).join('');
        }

        // Default
        return 'I can help you with:<br><br>'
            + '• <strong>Show all my vehicles</strong><br>'
            + '• <strong>Which vehicles are under maintenance?</strong><br>'
            + '• <strong>Which vehicles have PMS overdue?</strong><br>'
            + '• <strong>Which vehicles have PMS due soon?</strong><br>'
            + '• <strong>Show maintenance history</strong>';
    }

    // ── Vehicle History Modal ────────────────────────────────────────────────
    window.viewVehicleHistory = function (plateNumber) {
        var asset = assets.find(function (a) { return a.plateNumber === plateNumber; });
        if (!asset) return;

        document.getElementById('vehicleHistoryModal').classList.add('active');
        document.getElementById('historyVehiclePlate').textContent = plateNumber;
        document.getElementById('historyVehicleName').textContent = asset.assetDescription;

        var tableEl = document.getElementById('vehicleHistoryTable');
        if (!tableEl) return;

        if (!asset.maintenanceHistory || asset.maintenanceHistory.length === 0) {
            tableEl.innerHTML = '<div style="padding:2rem;text-align:center;color:#718096;">No maintenance history available.</div>';
        } else {
            tableEl.innerHTML = asset.maintenanceHistory.map(function (r) {
                return '<div class="table-row">'
                    + '<div><strong>' + r.service + '</strong><br><small style="color:#718096;">' + new Date(r.date).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' }) + '</small></div>'
                    + '<div><div>Parts: ' + r.parts + '</div><div>KM: ' + r.km.toLocaleString() + '</div></div>'
                    + '<div><div style="font-weight:bold;color:#38a169;">₱' + r.cost.toLocaleString() + '</div></div>'
                    + '</div>';
            }).join('');
        }
    };

})();
