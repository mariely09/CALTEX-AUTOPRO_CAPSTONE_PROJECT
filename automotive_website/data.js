// data.js — Shared app data, loaded by all portals instead of the full script.js

window.assets = [
    {
        id: 1, assetNum: 'ASSET-001', plateNumber: 'ABC-1234',
        assetDescription: 'Isuzu Truck NQR 2021', type: 'truck', icon: '🚛',
        brand: 'Isuzu', model: 'NQR', yearModel: 2021,
        engineNo: 'ENG-ABC-001', chassisNo: 'CHS-ABC-001',
        dateAcquired: '2021-03-15', owner: 'John Doe',
        odometer: 45230, status: 'active',
        lastServiceDate: '2026-01-15', nextPMSDue: '2026-03-15',
        serviceFrequency: 2, assignedMechanic: null, image: null,
        meters: [
            { name: 'Odometer', type: 'continuous', value: '45230', unit: 'km' },
            { name: 'Engine Hours', type: 'continuous', value: '1250', unit: 'hours' }
        ],
        maintenanceHistory: [
            { date: '2026-01-15', service: 'Change Oil', parts: 'Engine Oil', km: 45230, cost: 450 },
            { date: '2025-12-10', service: 'Brake Inspection', parts: 'None', km: 43100, cost: 0 },
            { date: '2025-11-05', service: 'Full PMS', parts: 'Oil, Filters', km: 40000, cost: 2350 }
        ]
    },
    {
        id: 2, assetNum: 'ASSET-002', plateNumber: 'DEF-2345',
        assetDescription: 'Isuzu Truck ELF 2020', type: 'truck', icon: '🚛',
        brand: 'Isuzu', model: 'ELF', yearModel: 2020,
        engineNo: 'ENG-DEF-002', chassisNo: 'CHS-DEF-002',
        dateAcquired: '2020-06-10', owner: 'John Doe',
        odometer: 78450, status: 'active',
        lastServiceDate: '2025-12-20', nextPMSDue: '2026-03-30',
        serviceFrequency: 2, assignedMechanic: null, image: null,
        meters: [
            { name: 'Odometer', type: 'continuous', value: '78450', unit: 'km' },
            { name: 'Engine Hours', type: 'continuous', value: '2100', unit: 'hours' }
        ],
        maintenanceHistory: [
            { date: '2025-12-20', service: 'Full PMS', parts: 'Oil, Filters, Belts', km: 78450, cost: 3200 },
            { date: '2025-10-05', service: 'Change Oil', parts: 'Engine Oil', km: 73200, cost: 450 }
        ]
    },
    {
        id: 3, assetNum: 'ASSET-003', plateNumber: 'GHI-3456',
        assetDescription: 'Isuzu Truck FVR 2022', type: 'truck', icon: '🚛',
        brand: 'Isuzu', model: 'FVR', yearModel: 2022,
        engineNo: 'ENG-GHI-003', chassisNo: 'CHS-GHI-003',
        dateAcquired: '2022-01-20', owner: 'John Doe',
        odometer: 32100, status: 'active',
        lastServiceDate: '2026-02-01', nextPMSDue: '2026-04-01',
        serviceFrequency: 2, assignedMechanic: null, image: null,
        meters: [
            { name: 'Odometer', type: 'continuous', value: '32100', unit: 'km' },
            { name: 'Engine Hours', type: 'continuous', value: '890', unit: 'hours' }
        ],
        maintenanceHistory: [
            { date: '2026-02-01', service: 'Change Oil', parts: 'Engine Oil', km: 32100, cost: 450 },
            { date: '2025-11-15', service: 'Brake Inspection', parts: 'Brake Pads', km: 28500, cost: 1200 }
        ]
    },
    {
        id: 4, assetNum: 'ASSET-004', plateNumber: 'JKL-4567',
        assetDescription: 'Isuzu Truck NPR 2019', type: 'truck', icon: '🚛',
        brand: 'Isuzu', model: 'NPR', yearModel: 2019,
        engineNo: 'ENG-JKL-004', chassisNo: 'CHS-JKL-004',
        dateAcquired: '2019-09-05', owner: 'John Doe',
        odometer: 112300, status: 'maintenance',
        lastServiceDate: '2026-01-10', nextPMSDue: '2026-03-10',
        serviceFrequency: 2, assignedMechanic: null, image: null,
        meters: [
            { name: 'Odometer', type: 'continuous', value: '112300', unit: 'km' },
            { name: 'Engine Hours', type: 'continuous', value: '3450', unit: 'hours' }
        ],
        maintenanceHistory: [
            { date: '2026-01-10', service: 'Full PMS', parts: 'Oil, Filters, Spark Plugs', km: 112300, cost: 4500 },
            { date: '2025-09-20', service: 'Tire Replacement', parts: 'Radial Tires x4', km: 105000, cost: 34000 }
        ]
    },
    {
        id: 5, assetNum: 'ASSET-005', plateNumber: 'MNO-5678',
        assetDescription: 'Isuzu Truck CYZ 2023', type: 'truck', icon: '🚛',
        brand: 'Isuzu', model: 'CYZ', yearModel: 2023,
        engineNo: 'ENG-MNO-005', chassisNo: 'CHS-MNO-005',
        dateAcquired: '2023-05-12', owner: 'John Doe',
        odometer: 18750, status: 'active',
        lastServiceDate: '2026-02-10', nextPMSDue: '2026-04-10',
        serviceFrequency: 2, assignedMechanic: null, image: null,
        meters: [
            { name: 'Odometer', type: 'continuous', value: '18750', unit: 'km' },
            { name: 'Engine Hours', type: 'continuous', value: '520', unit: 'hours' }
        ],
        maintenanceHistory: [
            { date: '2026-02-10', service: 'Change Oil', parts: 'Engine Oil', km: 18750, cost: 450 },
            { date: '2025-12-01', service: 'General Inspection', parts: 'None', km: 15200, cost: 0 }
        ]
    }
];

window.serviceTransactions = [
    {
        serviceId: 'SVC-001',
        dateServiced: '2026-03-20',
        assetNum: 'ASSET-004',
        assetDescription: 'Isuzu Truck NPR 2019',
        mechanicName: 'Juan Dela Cruz',
        servicesRendered: [
            { description: 'Full PMS - Engine Overhaul', quantity: 1, uom: 'Service', cost: 3500 },
            { description: 'Brake System Check', quantity: 1, uom: 'Service', cost: 1000 }
        ],
        spareParts: [
            { itemNum: 'INV-001', name: 'Engine Oil 5W-30', quantity: 4, uom: 'liters', cost: 1800 },
            { itemNum: 'INV-002', name: 'Brake Pads Set', quantity: 1, uom: 'sets', cost: 1200 }
        ],
        status: 'ongoing',
        totalCost: 7500,
        createdBy: 'Administrator',
        createdOn: '2026-03-20T08:00:00.000Z'
    },
    {
        serviceId: 'SVC-002',
        dateServiced: '2026-03-22',
        assetNum: 'ASSET-002',
        assetDescription: 'Isuzu Truck ELF 2020',
        mechanicName: 'Pedro Santos',
        servicesRendered: [
            { description: 'Change Oil Service', quantity: 1, uom: 'Service', cost: 450 },
            { description: 'General Inspection', quantity: 1, uom: 'Service', cost: 0 }
        ],
        spareParts: [
            { itemNum: 'INV-001', name: 'Engine Oil 5W-30', quantity: 6, uom: 'liters', cost: 2700 },
            { itemNum: 'INV-003', name: 'Air Filter', quantity: 1, uom: 'units', cost: 350 }
        ],
        status: 'pending',
        totalCost: 3500,
        createdBy: 'Staff User',
        createdOn: '2026-03-22T09:30:00.000Z'
    },
    {
        serviceId: 'SVC-003',
        dateServiced: '2026-03-10',
        assetNum: 'ASSET-001',
        assetDescription: 'Isuzu Truck NQR 2021',
        mechanicName: 'Juan Dela Cruz',
        servicesRendered: [
            { description: 'Tire Rotation & Balancing', quantity: 1, uom: 'Service', cost: 800 },
            { description: 'Brake Inspection', quantity: 1, uom: 'Service', cost: 500 }
        ],
        spareParts: [
            { itemNum: 'INV-002', name: 'Brake Pads Set', quantity: 2, uom: 'sets', cost: 2400 }
        ],
        status: 'completed',
        totalCost: 3700,
        createdBy: 'Administrator',
        createdOn: '2026-03-10T07:00:00.000Z'
    },
    {
        serviceId: 'SVC-004',
        dateServiced: '2026-03-05',
        assetNum: 'ASSET-003',
        assetDescription: 'Isuzu Truck FVR 2022',
        mechanicName: 'Mario Reyes',
        servicesRendered: [
            { description: 'Full PMS Service', quantity: 1, uom: 'Service', cost: 2500 }
        ],
        spareParts: [
            { itemNum: 'INV-001', name: 'Engine Oil 5W-30', quantity: 8, uom: 'liters', cost: 3600 },
            { itemNum: 'INV-003', name: 'Air Filter', quantity: 2, uom: 'units', cost: 700 },
            { itemNum: 'INV-004', name: 'Radial Tire 10R22.5', quantity: 2, uom: 'units', cost: 17000 }
        ],
        status: 'completed',
        totalCost: 23800,
        createdBy: 'Administrator',
        createdOn: '2026-03-05T08:00:00.000Z'
    }
];

window.inventory = [
    { id: 1, itemNum: 'INV-001', itemId: 'ENG-OIL-001', itemName: 'Engine Oil 5W-30', commodityGroup: 'Lubricants', stock: 5, unit: 'liters', price: 450.00, minLevel: 10, maxLevel: 50, reorderQty: 20, reorderLevel: 20, status: 'low_stock' },
    { id: 2, itemNum: 'INV-002', itemId: 'BRK-PAD-002', itemName: 'Brake Pads Set',   commodityGroup: 'Spare Parts', stock: 2, unit: 'sets',   price: 1200.00, minLevel: 5,  maxLevel: 20, reorderQty: 10, reorderLevel: 10, status: 'low_stock' },
    { id: 3, itemNum: 'INV-003', itemId: 'FLT-AIR-003', itemName: 'Air Filter',        commodityGroup: 'Filter',      stock: 15, unit: 'units', price: 350.00,  minLevel: 8,  maxLevel: 40, reorderQty: 15, reorderLevel: 15, status: 'in_stock' },
    { id: 4, itemNum: 'INV-004', itemId: 'TIR-RAD-004', itemName: 'Radial Tire 10R22.5', commodityGroup: 'Spare Parts', stock: 8, unit: 'units', price: 8500.00, minLevel: 4, maxLevel: 16, reorderQty: 8, reorderLevel: 8, status: 'in_stock' }
];

window.issuances = [
    // From SVC-003 (completed) — Brake Pads x2 for ASSET-001
    { id: 1, date: '2026-03-10', assetNum: 'ASSET-001', itemNum: 'INV-002', itemName: 'Brake Pads Set',      itemType: 'Material', commodityGroup: 'Spare Parts', uom: 'sets',   quantity: 2, unitCost: 1200.00, serviceId: 'SVC-003', issuedBy: 'Administrator' },
    // From SVC-003 (completed) — services rendered
    { id: 2, date: '2026-03-10', assetNum: 'ASSET-001', itemNum: '-',       itemName: 'Tire Rotation & Balancing', itemType: 'Service', commodityGroup: 'AutoService', uom: 'Service', quantity: 1, unitCost: 800.00,  serviceId: 'SVC-003', issuedBy: 'Administrator' },
    { id: 3, date: '2026-03-10', assetNum: 'ASSET-001', itemNum: '-',       itemName: 'Brake Inspection',          itemType: 'Service', commodityGroup: 'AutoService', uom: 'Service', quantity: 1, unitCost: 500.00,  serviceId: 'SVC-003', issuedBy: 'Administrator' },
    // From SVC-004 (completed) — spare parts for ASSET-003
    { id: 4, date: '2026-03-05', assetNum: 'ASSET-003', itemNum: 'INV-001', itemName: 'Engine Oil 5W-30',    itemType: 'Material', commodityGroup: 'Lubricants',  uom: 'liters', quantity: 8, unitCost: 450.00,  serviceId: 'SVC-004', issuedBy: 'Administrator' },
    { id: 5, date: '2026-03-05', assetNum: 'ASSET-003', itemNum: 'INV-003', itemName: 'Air Filter',          itemType: 'Material', commodityGroup: 'Filter',      uom: 'units',  quantity: 2, unitCost: 350.00,  serviceId: 'SVC-004', issuedBy: 'Administrator' },
    { id: 6, date: '2026-03-05', assetNum: 'ASSET-003', itemNum: 'INV-004', itemName: 'Radial Tire 10R22.5', itemType: 'Material', commodityGroup: 'Spare Parts', uom: 'units',  quantity: 2, unitCost: 8500.00, serviceId: 'SVC-004', issuedBy: 'Administrator' },
    // From SVC-004 (completed) — service rendered
    { id: 7, date: '2026-03-05', assetNum: 'ASSET-003', itemNum: '-',       itemName: 'Full PMS Service',    itemType: 'Service',  commodityGroup: 'AutoService', uom: 'Service', quantity: 1, unitCost: 2500.00, serviceId: 'SVC-004', issuedBy: 'Administrator' }
];

// Convenience alias so code using bare `assets` still works
var assets = window.assets;

window.itemMaster = [
    { itemNum: 'ITM-001', itemId: 'ENG-OIL-001', itemName: 'Engine Oil 5W-30', description: 'Premium synthetic engine oil 5W-30', sku: '001', barcode: '1234567890123', qrcode: 'QR-ENG-OIL-001', commodityGroup: 'Lubricants', uom: 'liters', cost: 450.00, itemType: 'Material' },
    { itemNum: 'ITM-002', itemId: 'BRK-PAD-002',  itemName: 'Brake Pads Set',   description: 'Heavy duty brake pads for trucks',   sku: '002', barcode: '2345678901234', qrcode: 'QR-BRK-PAD-002', commodityGroup: 'Spare Parts', uom: 'sets',   cost: 1200.00, itemType: 'Material' },
    { itemNum: 'ITM-003', itemId: 'FLT-AIR-003',  itemName: 'Air Filter',        description: 'Standard air filter for diesel engines', sku: '003', barcode: '3456789012345', qrcode: 'QR-FLT-AIR-003', commodityGroup: 'Filter', uom: 'units', cost: 350.00, itemType: 'Material' },
    { itemNum: 'ITM-004', itemId: 'TIR-RAD-004',  itemName: 'Radial Tire 10R22.5', description: 'Heavy duty radial tire for trucks', sku: '004', barcode: '4567890123456', qrcode: 'QR-TIR-RAD-004', commodityGroup: 'Spare Parts', uom: 'units', cost: 8500.00, itemType: 'Material' },
    { itemNum: 'ITM-005', itemId: 'SVC-PMS-005',  itemName: 'Full PMS Service',  description: 'Complete preventive maintenance service', sku: '005', barcode: '', qrcode: '', commodityGroup: 'AutoService', uom: 'Hour', cost: 2500.00, itemType: 'Service' },
    { itemNum: 'ITM-006', itemId: 'SVC-OIL-006',  itemName: 'Change Oil Service', description: 'Engine oil change service', sku: '006', barcode: '', qrcode: '', commodityGroup: 'AutoService', uom: 'Hour', cost: 450.00, itemType: 'Service' }
];

window.deliveryRecords = [];

window.domains = [
    { id: 'AssetType',      name: 'Asset Type',        list: ['Car', 'Truck', 'Bus', 'Van', 'Motorcycle'] },
    { id: 'UOM',            name: 'Unit of Measure',   list: ['Each', 'Set', 'sets', 'Hour', 'Piece', 'Litres', 'liters', 'Gallon', 'units', 'Service'] },
    { id: 'CommodityGroup', name: 'Commodity Group',   list: ['Lubricants', 'Spare Parts', 'Filter', 'AutoService'] },
    { id: 'ServiceType',    name: 'Service Type',      list: ['Change Oil', 'Full PMS', 'Brake Inspection', 'Tire Replacement', 'General Inspection'] }
];

// Bare aliases for code that references these without window. prefix
var itemMaster = window.itemMaster;
var deliveryRecords = window.deliveryRecords;
var domains = window.domains;
var inventory = window.inventory;
var issuances = window.issuances;
var serviceTransactions = window.serviceTransactions;

// Counters
window.nextAssetId = window.assets.length + 1;
var nextAssetId = window.nextAssetId;
