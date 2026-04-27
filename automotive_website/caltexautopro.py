from flask import Flask, render_template

app = Flask(__name__)

# ── Landing / Home ──────────────────────────────────────────
@app.route('/')
@app.route('/index.html')
def index():
    return render_template('index.html')

# ── Auth ────────────────────────────────────────────────────
@app.route('/login.html')
def login():
    return render_template('login.html')

@app.route('/forgot_password.html')
def forgot_password():
    return render_template('forgot_password.html')

# ── Admin ────────────────────────────────────────────────────
@app.route('/admin_dashboard.html')
def admin_dashboard():
    return render_template('admin_dashboard.html')

@app.route('/admin_inventory_itemaster.html')
def admin_inventory_items():
    return render_template('admin_inventory_itemaster.html')

@app.route('/admin_inventory_stock.html')
def admin_inventory_stock():
    return render_template('admin_inventory_stock.html')

@app.route('/admin_vehicle_list.html')
def admin_vehicles():
    return render_template('admin_vehicle_list.html')

@app.route('/admin_vehicle_maintenance.html')
def admin_vehicle_maintenance():
    return render_template('admin_vehicle_maintenance.html')

@app.route('/admin_users.html')
def admin_users():
    return render_template('admin_users.html')

@app.route('/admin_dss.html')
def admin_dss():
    return render_template('admin_dss.html')

@app.route('/admin_smart_reports.html')
def admin_smart_reports():
    return render_template('admin_smart_reports.html')

@app.route('/admin_domain_management.html')
def admin_domains():
    return render_template('admin_domain_management.html')

@app.route('/admin_sidebar.html')
def admin_sidebar():
    return render_template('admin_sidebar.html')

@app.route('/admin_header.html')
def admin_header():
    return render_template('admin_header.html')

# ── Staff ────────────────────────────────────────────────────
@app.route('/staff_dashboard.html')
def staff_dashboard():
    return render_template('staff_dashboard.html')

@app.route('/staff_inventory.html')
def staff_inventory():
    return render_template('staff_inventory.html')

@app.route('/staff_maintenance.html')
def staff_maintenance():
    return render_template('staff_maintenance.html')

@app.route('/staff_vehicle_list.html')
def staff_vehicle_list():
    return render_template('staff_vehicle_list.html')

# ── Customer ─────────────────────────────────────────────────
@app.route('/customer_dashboard.html')
def customer_dashboard():
    return render_template('customer_dashboard.html')

@app.route('/customer_pms_history.html')
def customer_pms_history():
    return render_template('customer_pms_history.html')

@app.route('/customer_smart_ai.html')
def customer_smart_ai():
    return render_template('customer_smart_ai.html')

@app.route('/customer_header.html')
def customer_header():
    return render_template('customer_header.html')

# ── Run ──────────────────────────────────────────────────────
if __name__ == '__main__':
    app.run(debug=True, host='127.0.0.1', port=5000)
