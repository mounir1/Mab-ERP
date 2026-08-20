-- ============================================================================
-- MAB ERP - Demo dataset seed
-- Populates a realistic demo dataset for the default company
-- (company_id 00000000-0000-0000-0000-000000000002, fiscal year 2025).
-- Idempotent: safe to re-run (ON CONFLICT (id) DO NOTHING on every insert).
--
-- Run:  .dev\pg\pgsql\bin\psql.exe -h 127.0.0.1 -U postgres -d mab_erp -f scripts\seed_demo.sql
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------------------
-- Reference IDs (already present)
-- ---------------------------------------------------------------------------
-- company     : 00000000-0000-0000-0000-000000000002
-- admin user  : 00000000-0000-0000-0000-000000000003
-- fiscal year : 00000000-0000-0000-0000-000000000011  (2025)
-- warehouse   : 00000000-0000-0000-0000-000000000010  (WH01)
-- currency    : 956cfdb5-2629-4364-b652-3bd649bf45cc  (DZD)
-- taxes       : 19% b36bffb9-c477-440d-b5ed-966552656539
--             :  9% 08c3a5b5-51bf-4f73-a031-f4d34a7309ba
--             :  0% 20ac31a3-8879-45d6-be2b-2840f6fff2db
--             : TAP 1856528d-e191-44e9-a1a4-fb63a4553ff7

-- ============================================================================
-- 1. ORGANIZATION
-- ============================================================================

INSERT INTO branches (id, company_id, code, name, address, city, phone, is_active, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000002','B001','Siège social','Route Nationale 5, Zone Industrielle','Alger','021 45 67 89',true,now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO departments (id, company_id, code, name, parent_id, is_active, created_at) VALUES
('a0000000-0000-0000-0000-000000000010','00000000-0000-0000-0000-000000000002','PROD','Production',NULL,true,now()),
('a0000000-0000-0000-0000-000000000011','00000000-0000-0000-0000-000000000002','SALES','Ventes',NULL,true,now()),
('a0000000-0000-0000-0000-000000000012','00000000-0000-0000-0000-000000000002','HR','Ressources Humaines',NULL,true,now()),
('a0000000-0000-0000-0000-000000000013','00000000-0000-0000-0000-000000000002','FIN','Finance & Comptabilité',NULL,true,now()),
('a0000000-0000-0000-0000-000000000014','00000000-0000-0000-0000-000000000002','MANT','Maintenance',NULL,true,now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO positions (id, company_id, department_id, code, title, grade, min_salary, max_salary, is_active, created_at) VALUES
('a0000000-0000-0000-0000-000000000020','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000010','RESP-PROD','Responsable Production','A',120000,180000,true,now()),
('a0000000-0000-0000-0000-000000000021','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000013','COMPTABLE','Comptable','B',80000,120000,true,now()),
('a0000000-0000-0000-0000-000000000022','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000011','COMMERCIAL','Commercial','B',70000,110000,true,now()),
('a0000000-0000-0000-0000-000000000023','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000014','TECHNICIEN','Technicien de maintenance','C',60000,90000,true,now())
ON CONFLICT (id) DO NOTHING;

-- 2 additional employees (Mounir already exists: 1a05d22b-713c-48fb-9bea-5c539012a688)
INSERT INTO employees (id, company_id, branch_id, employee_number, first_name, last_name, gender, birth_date, hire_date, national_id, cnas_number, nif, department_id, position_id, employment_type, status, base_salary, bank_account, bank_name, email, phone, address, city, wilaya, user_id, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000030','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000001','EMP-0002','Fatima Zahra','Benali','F','1990-03-14','2018-01-15','199014033456789','C12345678','0991122334455','a0000000-0000-0000-0000-000000000013','a0000000-0000-0000-0000-000000000021','full_time','active',95000,'DZD1234567890','BNA','fatima.benali@example.com','0550 12 34 56','Cité 20 Août','Alger','16',NULL,now(),now()),
('a0000000-0000-0000-0000-000000000031','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000001','EMP-0003','Karim','Haddad','M','1992-07-22','2020-03-01','199222077654321','C98765432','0990333444555','a0000000-0000-0000-0000-000000000011','a0000000-0000-0000-0000-000000000022','full_time','active',85000,'DZD0987654321','CPA','karim.haddad@example.com','0551 98 76 54','Boulevard Zighout Youcef','Alger','16',NULL,now(),now()),
('a0000000-0000-0000-0000-000000000032','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000001','EMP-0004','Sara','Cherif','F','1988-11-05','2016-09-12','198811055112233','C11223344','0990111222333','a0000000-0000-0000-0000-000000000010','a0000000-0000-0000-0000-000000000020','full_time','active',130000,'DZD5566778899','CPA','sara.cherif@example.com','0552 33 44 55','Cité Universitaire','Alger','16',NULL,now(),now())
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 2. INVENTORY MASTER DATA
-- ---------------------------------------------------------------------------

INSERT INTO units_of_measure (id, company_id, code, name, category, factor) VALUES
('a0000000-0000-0000-0000-000000000040','00000000-0000-0000-0000-000000000002','PC','Pièce','unit',1),
('a0000000-0000-0000-0000-000000000041','00000000-0000-0000-0000-000000000002','KG','Kilogramme','weight',1),
('a0000000-0000-0000-0000-000000000042','00000000-0000-0000-0000-000000000002','L','Litre','volume',1),
('a0000000-0000-0000-0000-000000000043','00000000-0000-0000-0000-000000000002','BOX','Carton','unit',1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO item_categories (id, company_id, code, name, parent_id, account_id, created_at) VALUES
('a0000000-0000-0000-0000-000000000050','00000000-0000-0000-0000-000000000002','RAW','Matières premières',NULL,'b4269cbd-3091-433f-b05e-9514b063dd9a',now()),
('a0000000-0000-0000-0000-000000000051','00000000-0000-0000-0000-000000000002','FIN','Produits finis',NULL,'b7809f70-e2be-43d1-8318-1d160df81f8b',now()),
('a0000000-0000-0000-0000-000000000052','00000000-0000-0000-0000-000000000002','PKG','Emballages',NULL,'094568bd-4936-4afa-9903-163a77ff2b0c',now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO items (id, company_id, code, name, description, category_id, uom_id, item_type, track_inventory, tva_rate, cost_method, standard_cost, cmup_cost, sale_price, min_stock_qty, reorder_qty, max_stock_qty, inventory_account_id, cogs_account_id, revenue_account_id, is_active, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000060','00000000-0000-0000-0000-000000000002','MP-FARINE','Farine de blé','Farine de blé tendre 50kg','a0000000-0000-0000-0000-000000000050','a0000000-0000-0000-0000-000000000041','storable',true,19,'cmup',2500,2500,2800,100,150,500,'b4269cbd-3091-433f-b05e-9514b063dd9a','c84680f5-6b14-41f6-86e4-093495d413fc','078338da-5362-4564-89f9-4b18aad2a0fa',true,now(),now()),
('a0000000-0000-0000-0000-000000000061','00000000-0000-0000-0000-000000000002','MP-SUCRE','Sucre blanc','Sucre blanc sac 50kg','a0000000-0000-0000-0000-000000000050','a0000000-0000-0000-0000-000000000041','storable',true,19,'cmup',4500,4500,4900,50,100,300,'b4269cbd-3091-433f-b05e-9514b063dd9a','c84680f5-6b14-41f6-86e4-093495d413fc','078338da-5362-4564-89f9-4b18aad2a0fa',true,now(),now()),
('a0000000-0000-0000-0000-000000000062','00000000-0000-0000-0000-000000000002','MP-HUILE','Huile végétale','Huile végétale raffinée 20L','a0000000-0000-0000-0000-000000000050','a0000000-0000-0000-0000-000000000042','storable',true,19,'cmup',6800,6800,7200,40,80,250,'b4269cbd-3091-433f-b05e-9514b063dd9a','c84680f5-6b14-41f6-86e4-093495d413fc','078338da-5362-4564-89f9-4b18aad2a0fa',true,now(),now()),
('a0000000-0000-0000-0000-000000000063','00000000-0000-0000-0000-000000000002','PF-BISCUIT','Biscuits sablés','Biscuits sablés paquet 500g','a0000000-0000-0000-0000-000000000051','a0000000-0000-0000-0000-000000000043','storable',true,19,'cmup',180,180,240,500,1000,5000,'b7809f70-e2be-43d1-8318-1d160df81f8b','c84680f5-6b14-41f6-86e4-093495d413fc','078338da-5362-4564-89f9-4b18aad2a0fa',true,now(),now()),
('a0000000-0000-0000-0000-000000000064','00000000-0000-0000-0000-000000000002','PF-GATEAU','Gâteaux aux dattes','Gâteaux aux dattes boîte 1kg','a0000000-0000-0000-0000-000000000051','a0000000-0000-0000-0000-000000000043','storable',true,19,'cmup',450,450,560,300,600,3000,'b7809f70-e2be-43d1-8318-1d160df81f8b','c84680f5-6b14-41f6-86e4-093495d413fc','078338da-5362-4564-89f9-4b18aad2a0fa',true,now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO stock_levels (id, company_id, item_id, warehouse_id, location_id, qty_on_hand, qty_reserved, cmup_cost, updated_at) VALUES
('a0000000-0000-0000-0000-000000000220','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000060','00000000-0000-0000-0000-000000000010','b634dbc9-094f-4d15-89dc-ec28212dbd2f',200,0,2500,now()),
('a0000000-0000-0000-0000-000000000221','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000061','00000000-0000-0000-0000-000000000010','b634dbc9-094f-4d15-89dc-ec28212dbd2f',150,0,4500,now()),
('a0000000-0000-0000-0000-000000000222','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000062','00000000-0000-0000-0000-000000000010','b634dbc9-094f-4d15-89dc-ec28212dbd2f',80,0,6800,now()),
('a0000000-0000-0000-0000-000000000223','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000063','00000000-0000-0000-0000-000000000010','b634dbc9-094f-4d15-89dc-ec28212dbd2f',3000,0,180,now()),
('a0000000-0000-0000-0000-000000000224','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000064','00000000-0000-0000-0000-000000000010','b634dbc9-094f-4d15-89dc-ec28212dbd2f',1200,0,450,now())
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 3. CRM / SALES
-- ---------------------------------------------------------------------------

INSERT INTO customers (id, company_id, code, name, type, nif, nis, rc, address, city, wilaya, phone, email, credit_limit, balance, payment_terms, account_id, salesperson_id, is_active, notes, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000080','00000000-0000-0000-0000-000000000002','C0001','Sarl Distribution Algéroise','company','0999123456789','0998012345678','16/00-1234567B23','Rue Didouche Mourad 12','Alger','16','021 63 21 54','contact@distrib-alger.dz',5000000,0,30,'bc7ee282-54b7-42f3-9875-81315805db79','a0000000-0000-0000-0000-000000000031',true,'Grossiste alimentaire',now(),now()),
('a0000000-0000-0000-0000-000000000081','00000000-0000-0000-0000-000000000002','C0002','Eurl Marché Plus','company','0998234567890','0997012345678','16/00-2233445A12','Cité 5 Juillet','Oran','31','041 33 44 55','contact@marcheplus.dz',3000000,0,15,'bc7ee282-54b7-42f3-9875-81315805db79','a0000000-0000-0000-0000-000000000031',true,'Supermarché',now(),now()),
('a0000000-0000-0000-0000-000000000082','00000000-0000-0000-0000-000000000002','C0003','Snc Cash & Carry','company','0997334567890','0996012345678','31/00-3344556C45','Zone d''activité Palmeraie','Oran','31','041 55 66 77','contact@cashcarry.dz',8000000,0,45,'bc7ee282-54b7-42f3-9875-81315805db79','a0000000-0000-0000-0000-000000000031',true,'Cash & carry',now(),now()),
('a0000000-0000-0000-0000-000000000083','00000000-0000-0000-0000-000000000002','C0004','Sarl Epicerie Moderne','individual','0996334567890','0995012345678','16/00-4455667D67','Rue des Frères Bouadou','Alger','16','021 77 88 99','contact@epicerie-moderne.dz',1500000,0,0,'bc7ee282-54b7-42f3-9875-81315805db79','a0000000-0000-0000-0000-000000000031',true,'Épicerie de quartier',now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO leads (id, company_id, title, first_name, last_name, company_name, email, phone, source, status, salesperson_id, notes, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000090','00000000-0000-0000-0000-000000000002','','Ahmed','Brahimi','Sarl Fruits du Sud','ahmed.brahimi@fruits-sud.dz','0555 11 22 33','website','new','a0000000-0000-0000-0000-000000000031','Intéressé par les gâteaux aux dattes',now(),now()),
('a0000000-0000-0000-0000-000000000091','00000000-0000-0000-0000-000000000002','','Lamia','Slimani','Eurl Bio Nature','lamia.slimani@bio-nature.dz','0556 44 55 66','referral','contacted','a0000000-0000-0000-0000-000000000031','Demande de catalogue',now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO opportunities (id, company_id, customer_id, lead_id, name, stage, amount, probability, expected_close, salesperson_id, notes, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-0000000000A0','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000080','a0000000-0000-0000-0000-000000000090','Contrat annuel biscuits','proposal',1200000,60,'2025-08-30','a0000000-0000-0000-0000-000000000031','Livraison hebdomadaire',now(),now()),
('a0000000-0000-0000-0000-0000000000A1','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000081','a0000000-0000-0000-0000-000000000091','Gamme gâteaux Oran','qualified',800000,40,'2025-09-15','a0000000-0000-0000-0000-000000000031','Test de dégustation à organiser',now(),now())
ON CONFLICT (id) DO NOTHING;

-- Quotations
INSERT INTO quotations (id, company_id, branch_id, number, customer_id, date, valid_until, status, subtotal, discount_amount, tva_amount, stamp_tax, total_amount, currency, notes, terms, salesperson_id, created_by, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000700','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000001','QT-2025-0001','a0000000-0000-0000-0000-000000000080','2025-06-02','2025-07-02','accepted',540000,0,102600,0,642600,'DZD','Devis initial','Paiement à 30 jours','a0000000-0000-0000-0000-000000000031','00000000-0000-0000-0000-000000000003',now(),now()),
('a0000000-0000-0000-0000-000000000701','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000001','QT-2025-0002','a0000000-0000-0000-0000-000000000081','2025-06-10','2025-07-10','sent',135000,0,25650,0,160650,'DZD','Devis gâteaux','Paiement comptant','a0000000-0000-0000-0000-000000000031','00000000-0000-0000-0000-000000000003',now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO quotation_lines (id, quotation_id, item_id, description, quantity, unit_price, discount_pct, tva_rate, tva_amount, total, account_id, sort_order) VALUES
('a0000000-0000-0000-0000-000000000710','a0000000-0000-0000-0000-000000000700','a0000000-0000-0000-0000-000000000063','Biscuits sablés paquet 500g',2000,240,0,19,91200,571200,'078338da-5362-4564-89f9-4b18aad2a0fa',1),
('a0000000-0000-0000-0000-000000000711','a0000000-0000-0000-0000-000000000700','a0000000-0000-0000-0000-000000000064','Gâteaux aux dattes boîte 1kg',100,560,0,19,10640,66640,'078338da-5362-4564-89f9-4b18aad2a0fa',2),
('a0000000-0000-0000-0000-000000000712','a0000000-0000-0000-0000-000000000701','a0000000-0000-0000-0000-000000000064','Gâteaux aux dattes boîte 1kg',250,540,0,19,25650,160650,'078338da-5362-4564-89f9-4b18aad2a0fa',1)
ON CONFLICT (id) DO NOTHING;

-- Sales orders
INSERT INTO sales_orders (id, company_id, branch_id, number, quotation_id, customer_id, date, delivery_date, status, subtotal, discount_amount, tva_amount, stamp_tax, total_amount, currency, notes, created_by, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000720','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000001','SC-2025-0001','a0000000-0000-0000-0000-000000000700','a0000000-0000-0000-0000-000000000080','2025-06-03','2025-06-17','confirmed',540000,0,102600,0,642600,'DZD','Commande suite au devis QT-2025-0001','00000000-0000-0000-0000-000000000003',now(),now()),
('a0000000-0000-0000-0000-000000000721','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000001','SC-2025-0002','a0000000-0000-0000-0000-000000000701','a0000000-0000-0000-0000-000000000081','2025-06-11','2025-06-25','confirmed',135000,0,25650,0,160650,'DZD','Commande suite au devis QT-2025-0002','00000000-0000-0000-0000-000000000003',now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO sales_order_lines (id, order_id, item_id, description, quantity, unit_price, discount_pct, tva_rate, tva_amount, total, account_id, sort_order) VALUES
('a0000000-0000-0000-0000-000000000730','a0000000-0000-0000-0000-000000000720','a0000000-0000-0000-0000-000000000063','Biscuits sablés paquet 500g',2000,240,0,19,91200,571200,'078338da-5362-4564-89f9-4b18aad2a0fa',1),
('a0000000-0000-0000-0000-000000000731','a0000000-0000-0000-0000-000000000720','a0000000-0000-0000-0000-000000000064','Gâteaux aux dattes boîte 1kg',100,560,0,19,10640,66640,'078338da-5362-4564-89f9-4b18aad2a0fa',2),
('a0000000-0000-0000-0000-000000000732','a0000000-0000-0000-0000-000000000721','a0000000-0000-0000-0000-000000000064','Gâteaux aux dattes boîte 1kg',250,540,0,19,25650,160650,'078338da-5362-4564-89f9-4b18aad2a0fa',1)
ON CONFLICT (id) DO NOTHING;

-- Sales invoices
INSERT INTO sales_invoices (id, company_id, branch_id, number, order_id, customer_id, date, due_date, status, subtotal, discount_amount, tva_amount, stamp_tax, total_amount, paid_amount, currency, notes, journal_entry_id, confirmed_at, confirmed_by, created_by, created_at, updated_at, tap_amount) VALUES
('a0000000-0000-0000-0000-000000000740','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000001','FV-2025-0001','a0000000-0000-0000-0000-000000000720','a0000000-0000-0000-0000-000000000080','2025-06-05','2025-07-05','confirmed',540000,0,102600,0,642600,642600,'DZD','Facture du 5 juin',NULL,now(),'00000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000003',now(),now(),0)
ON CONFLICT (id) DO NOTHING;

INSERT INTO sales_invoice_lines (id, invoice_id, item_id, description, quantity, unit_price, discount_pct, tva_rate, tva_amount, total, account_id, sort_order) VALUES
('a0000000-0000-0000-0000-000000000750','a0000000-0000-0000-0000-000000000740','a0000000-0000-0000-0000-000000000063','Biscuits sablés paquet 500g',2000,240,0,19,91200,571200,'078338da-5362-4564-89f9-4b18aad2a0fa',1),
('a0000000-0000-0000-0000-000000000751','a0000000-0000-0000-0000-000000000740','a0000000-0000-0000-0000-000000000064','Gâteaux aux dattes boîte 1kg',100,560,0,19,10640,66640,'078338da-5362-4564-89f9-4b18aad2a0fa',2)
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 4. PURCHASE
-- ---------------------------------------------------------------------------

INSERT INTO suppliers (id, company_id, code, name, type, nif, nis, rc, address, city, wilaya, phone, email, payment_terms, credit_limit, balance, account_id, is_active, notes, created_at, updated_at, contact_name, rating) VALUES
('a0000000-0000-0000-0000-000000000070','00000000-0000-0000-0000-000000000002','F0001','Sarl Blé d''Or','company','0998123456789','0997012345678','16/00-5566778E78','Zone industrielle Rouiba','Alger','16','023 45 67 89','contact@bledor.dz',30,10000000,0,'b5dd9c8e-94f6-4ef8-98ba-d381c5ddc51c',true,'Fournisseur farine',now(),now(),'Mohamed Bensalem',5),
('a0000000-0000-0000-0000-000000000071','00000000-0000-0000-0000-000000000002','F0002','Eurl SucrePlus','company','0997123456789','0996012345678','16/00-6677889F89','Zone industrielle Oued Smar','Alger','16','023 78 90 12','contact@sugreplus.dz',30,8000000,0,'b5dd9c8e-94f6-4ef8-98ba-d381c5ddc51c',true,'Fournisseur sucre',now(),now(),'Amine Kerrouche',4),
('a0000000-0000-0000-0000-000000000072','00000000-0000-0000-0000-000000000002','F0003','Spa Huilerie du Sud','company','0996123456789','0995012345678','31/00-7788990A90','Route de l''aéroport','Sétif','19','036 45 67 89','contact@huilerie-sud.dz',45,12000000,0,'b5dd9c8e-94f6-4ef8-98ba-d381c5ddc51c',true,'Fournisseur huile',now(),now(),'Yacine Merabet',4)
ON CONFLICT (id) DO NOTHING;

-- RFQs
INSERT INTO rfqs (id, company_id, number, supplier_id, date, deadline, status, notes, created_by, created_at, updated_at, total_amount, subtotal, tva_amount, currency) VALUES
('a0000000-0000-0000-0000-000000000760','00000000-0000-0000-0000-000000000002','RFQ-2025-0001','a0000000-0000-0000-0000-000000000070','2025-05-20','2025-05-30','sent','Demande de prix farine','00000000-0000-0000-0000-000000000003',now(),now(),0,0,0,'DZD'),
('a0000000-0000-0000-0000-000000000761','00000000-0000-0000-0000-000000000002','RFQ-2025-0002','a0000000-0000-0000-0000-000000000071','2025-05-22','2025-06-01','sent','Demande de prix sucre','00000000-0000-0000-0000-000000000003',now(),now(),0,0,0,'DZD')
ON CONFLICT (id) DO NOTHING;

INSERT INTO rfq_lines (id, rfq_id, item_id, description, quantity, unit_price, discount_pct, tva_rate, subtotal, tva_amount, total, sort_order) VALUES
('a0000000-0000-0000-0000-000000000770','a0000000-0000-0000-0000-000000000760','a0000000-0000-0000-0000-000000000060','Farine de blé 50kg',100,2500,0,19,250000,47500,297500,1),
('a0000000-0000-0000-0000-000000000771','a0000000-0000-0000-0000-000000000761','a0000000-0000-0000-0000-000000000061','Sucre blanc 50kg',60,4500,0,19,270000,51300,321300,1)
ON CONFLICT (id) DO NOTHING;

-- Purchase orders
INSERT INTO purchase_orders (id, company_id, branch_id, number, rfq_id, supplier_id, date, expected_date, status, subtotal, discount_amount, tva_amount, total_amount, received_amount, currency, notes, approved_by, approved_at, journal_entry_id, created_by, created_at, updated_at, supplier_name, confirmed_at) VALUES
('a0000000-0000-0000-0000-000000000780','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000001','BC-2025-0001','a0000000-0000-0000-0000-000000000760','a0000000-0000-0000-0000-000000000070','2025-06-01','2025-06-15','approved',250000,0,47500,297500,0,'DZD','Commande farine','00000000-0000-0000-0000-000000000003',now(),NULL,'00000000-0000-0000-0000-000000000003',now(),now(),'Sarl Blé d''Or',now()),
('a0000000-0000-0000-0000-000000000781','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000001','BC-2025-0002','a0000000-0000-0000-0000-000000000761','a0000000-0000-0000-0000-000000000071','2025-06-03','2025-06-18','approved',270000,0,51300,321300,0,'DZD','Commande sucre','00000000-0000-0000-0000-000000000003',now(),NULL,'00000000-0000-0000-0000-000000000003',now(),now(),'Eurl SucrePlus',now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO purchase_order_lines (id, po_id, item_id, description, quantity, received_qty, unit_price, discount_pct, tva_rate, subtotal, tva_amount, total, account_id, sort_order, item_code, item_name) VALUES
('a0000000-0000-0000-0000-000000000790','a0000000-0000-0000-0000-000000000780','a0000000-0000-0000-0000-000000000060','Farine de blé 50kg',100,0,2500,0,19,250000,47500,297500,'c84680f5-6b14-41f6-86e4-093495d413fc',1,'MP-FARINE','Farine de blé'),
('a0000000-0000-0000-0000-000000000791','a0000000-0000-0000-0000-000000000781','a0000000-0000-0000-0000-000000000061','Sucre blanc 50kg',60,0,4500,0,19,270000,51300,321300,'c84680f5-6b14-41f6-86e4-093495d413fc',1,'MP-SUCRE','Sucre blanc')
ON CONFLICT (id) DO NOTHING;

-- Goods receipts
INSERT INTO goods_receipts (id, company_id, number, po_id, supplier_id, date, warehouse_id, status, notes, validated_by, validated_at, created_by, created_at, updated_at, supplier_name, total_amount) VALUES
('a0000000-0000-0000-0000-000000000792','00000000-0000-0000-0000-000000000002','BR-2025-0001','a0000000-0000-0000-0000-000000000780','a0000000-0000-0000-0000-000000000070','2025-06-16','00000000-0000-0000-0000-000000000010','validated','Réception conforme','00000000-0000-0000-0000-000000000003',now(),'00000000-0000-0000-0000-000000000003',now(),now(),'Sarl Blé d''Or',297500)
ON CONFLICT (id) DO NOTHING;

INSERT INTO goods_receipt_lines (id, grn_id, po_line_id, item_id, description, expected_qty, received_qty, unit_cost, item_code, item_name) VALUES
('a0000000-0000-0000-0000-000000000793','a0000000-0000-0000-0000-000000000792','a0000000-0000-0000-0000-000000000790','a0000000-0000-0000-0000-000000000060','Farine de blé 50kg',100,100,2500,'MP-FARINE','Farine de blé')
ON CONFLICT (id) DO NOTHING;

-- Purchase invoices
INSERT INTO purchase_invoices (id, company_id, number, supplier_ref, grn_id, po_id, supplier_id, date, due_date, status, subtotal, tva_amount, total_amount, paid_amount, currency, match_status, notes, journal_entry_id, created_by, created_at, updated_at, supplier_name) VALUES
('a0000000-0000-0000-0000-000000000794','00000000-0000-0000-0000-000000000002','FAF-2025-0001','FAC-2025-118','a0000000-0000-0000-0000-000000000792','a0000000-0000-0000-0000-000000000780','a0000000-0000-0000-0000-000000000070','2025-06-16','2025-07-16','confirmed',250000,47500,297500,0,'DZD','matched','Facture fournisseur',NULL,'00000000-0000-0000-0000-000000000003',now(),now(),'Sarl Blé d''Or')
ON CONFLICT (id) DO NOTHING;

INSERT INTO purchase_invoice_lines (id, invoice_id, po_line_id, item_id, description, quantity, unit_price, discount_pct, tva_rate, subtotal, tva_amount, total, account_id, sort_order) VALUES
('a0000000-0000-0000-0000-000000000795','a0000000-0000-0000-0000-000000000794','a0000000-0000-0000-0000-000000000790','a0000000-0000-0000-0000-000000000060','Farine de blé 50kg',100,2500,0,19,250000,47500,297500,'c84680f5-6b14-41f6-86e4-093495d413fc',1)
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 5. TREASURY
-- ---------------------------------------------------------------------------

INSERT INTO bank_accounts (id, company_id, branch_id, code, name, bank_name, account_number, rib, iban, swift, currency, balance, account_id, is_active, created_at, swift_code, branch, opening_balance, updated_at, notes) VALUES
('a0000000-0000-0000-0000-0000000000B0','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000001','BNA-001','Compte BNA','Banque Nationale d''Algérie','00123456789012','00123456789012','DZ000012345678901234567890','BNADZDZ','DZD',8500000,'bf0ceb84-fdfa-46cf-a85c-1481b0688ae9',true,now(),'BNADZDZ','Alger',5000000,now(),'Compte courant'),
('a0000000-0000-0000-0000-0000000000B1','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000001','CPA-001','Compte CPA','Crédit Populaire d''Algérie','00345678901234','00345678901234','DZ000034567890123456789012','CPADZDZ','DZD',4200000,'bf0ceb84-fdfa-46cf-a85c-1481b0688ae9',true,now(),'CPADZDZ','Alger',3000000,now(),'Compte épargne')
ON CONFLICT (id) DO NOTHING;

INSERT INTO cash_accounts (id, company_id, branch_id, code, name, account_id, currency, balance, is_active, created_at) VALUES
('a0000000-0000-0000-0000-0000000000C0','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000001','CSH-001','Caisse principale','4c2cd0dc-0fd4-4080-9d21-8cc8311f4fe5','DZD',350000,true,now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO treasury_movements (id, company_id, type, amount, date, reference, notes, category, reconciled, cash_account_id, bank_account_id, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000800','00000000-0000-0000-0000-000000000002','deposit',150000,'2025-06-20','DEP-2025-0001','Versement espèce en banque','deposit',false,'a0000000-0000-0000-0000-0000000000C0','a0000000-0000-0000-0000-0000000000B0',now(),now()),
('a0000000-0000-0000-0000-000000000801','00000000-0000-0000-0000-000000000002','withdrawal',200000,'2025-06-21','WTH-2025-0001','Retrait pour caisse','withdrawal',false,'a0000000-0000-0000-0000-0000000000C0','a0000000-0000-0000-0000-0000000000B0',now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO payments (id, company_id, number, payment_type, direction, date, amount, currency, cash_account_id, bank_account_id, cheque_id, partner_id, partner_type, invoice_id, invoice_type, reference, notes, journal_entry_id, created_by, created_at, updated_at, type, partner_name, allocated_amount, method, status) VALUES
('a0000000-0000-0000-0000-000000000810','00000000-0000-0000-0000-000000000002','PYT-2025-0001','bank_transfer','out','2025-06-22',297500,'DZD',NULL,'a0000000-0000-0000-0000-0000000000B0',NULL,'a0000000-0000-0000-0000-000000000070','supplier','a0000000-0000-0000-0000-000000000794','purchase','VIR-2025-8812','Paiement facture FAF-2025-0001',NULL,'00000000-0000-0000-0000-000000000003',now(),now(),'payment','Sarl Blé d''Or',297500,'bank_transfer','completed')
ON CONFLICT (id) DO NOTHING;

INSERT INTO receipts (id, company_id, number, receipt_type, status, partner_id, partner_name, amount, allocated_amount, receipt_date, reference, payment_method, currency, bank_account_id, cash_account_id, description, invoice_id, invoice_number, confirmed_at, notes, created_by, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000811','00000000-0000-0000-0000-000000000002','RCT-2025-0001','customer','completed','a0000000-0000-0000-0000-000000000080','Sarl Distribution Algéroise',642600,642600,'2025-06-25','CHQ-5588','cheque','DZD','a0000000-0000-0000-0000-0000000000B0',NULL,'Règlement facture FV-2025-0001','a0000000-0000-0000-0000-000000000740','FV-2025-0001',now(),'Chèque encaissé','00000000-0000-0000-0000-000000000003',now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO cheques (id, company_id, number, bank_account_id, cheque_type, amount, issue_date, due_date, payee_payer, status, deposited_at, cleared_at, bounced_at, bounce_reason, journal_entry_id, created_by, created_at, updated_at, type, partner_name, partner_id, notes) VALUES
('a0000000-0000-0000-0000-000000000812','00000000-0000-0000-0000-000000000002','CHQ-5588','a0000000-0000-0000-0000-0000000000B0','received',642600,'2025-06-20','2025-06-25','Sarl Distribution Algéroise','deposited','2025-06-20',NULL,NULL,NULL,NULL,'00000000-0000-0000-0000-000000000003',now(),now(),'received','Sarl Distribution Algéroise','a0000000-0000-0000-0000-000000000080','Chèque client')
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 6. STOCK MOVEMENTS
-- ---------------------------------------------------------------------------

INSERT INTO stock_movements (id, company_id, number, date, type, item_id, warehouse_id, from_location_id, to_warehouse_id, to_location_id, quantity, unit_cost, reference, source_type, source_id, notes, journal_entry_id, created_by, created_at) VALUES
('a0000000-0000-0000-0000-000000000820','00000000-0000-0000-0000-000000000002','MV-2025-0001','2025-06-16','purchase','a0000000-0000-0000-0000-000000000060','00000000-0000-0000-0000-000000000010',NULL,NULL,'b634dbc9-094f-4d15-89dc-ec28212dbd2f',100,2500,'BR-2025-0001','goods_receipt','a0000000-0000-0000-0000-000000000792','Réception farine',NULL,'00000000-0000-0000-0000-000000000003',now()),
('a0000000-0000-0000-0000-000000000821','00000000-0000-0000-0000-000000000002','MV-2025-0002','2025-06-05','sale','a0000000-0000-0000-0000-000000000063','00000000-0000-0000-0000-000000000010','b634dbc9-094f-4d15-89dc-ec28212dbd2f',NULL,NULL,2000,180,'FV-2025-0001','sales_invoice','a0000000-0000-0000-0000-000000000740','Sortie biscuits',NULL,'00000000-0000-0000-0000-000000000003',now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO inventory_counts (id, company_id, number, date, warehouse_id, status, notes, validated_by, validated_at, created_by, created_at) VALUES
('a0000000-0000-0000-0000-000000000822','00000000-0000-0000-0000-000000000002','INV-2025-0001','2025-06-30','00000000-0000-0000-0000-000000000010','completed','Inventaire de fin de mois','00000000-0000-0000-0000-000000000003',now(),'00000000-0000-0000-0000-000000000003',now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO inventory_count_lines (id, count_id, item_id, location_id, book_qty, counted_qty, unit_cost) VALUES
('a0000000-0000-0000-0000-000000000823','a0000000-0000-0000-0000-000000000822','a0000000-0000-0000-0000-000000000063','b634dbc9-094f-4d15-89dc-ec28212dbd2f',3000,2998,180),
('a0000000-0000-0000-0000-000000000824','a0000000-0000-0000-0000-000000000822','a0000000-0000-0000-0000-000000000064','b634dbc9-094f-4d15-89dc-ec28212dbd2f',1200,1200,450)
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 7. MANUFACTURING
-- ---------------------------------------------------------------------------

INSERT INTO work_centers (id, company_id, code, name, capacity, cost_per_hour, account_id, is_active, created_at) VALUES
('a0000000-0000-0000-0000-0000000000D0','00000000-0000-0000-0000-000000000002','WC-001','Mélangeur',100,1500,'c84680f5-6b14-41f6-86e4-093495d413fc',true,now()),
('a0000000-0000-0000-0000-0000000000D1','00000000-0000-0000-0000-000000000002','WC-002','Four de cuisson',80,2000,'c84680f5-6b14-41f6-86e4-093495d413fc',true,now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO bill_of_materials (id, company_id, code, product_id, version, quantity, uom_id, is_active, notes, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-0000000000E0','00000000-0000-0000-0000-000000000002','NOM-001','a0000000-0000-0000-0000-000000000063','V1',100,'a0000000-0000-0000-0000-000000000043',true,'Recette biscuits sablés',now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO bom_components (id, bom_id, component_id, quantity, uom_id, scrap_pct, sort_order) VALUES
('a0000000-0000-0000-0000-0000000000E1','a0000000-0000-0000-0000-0000000000E0','a0000000-0000-0000-0000-000000000060',5,'a0000000-0000-0000-0000-000000000041',2,1),
('a0000000-0000-0000-0000-0000000000E2','a0000000-0000-0000-0000-0000000000E0','a0000000-0000-0000-0000-000000000061',3,'a0000000-0000-0000-0000-000000000041',1,2),
('a0000000-0000-0000-0000-0000000000E3','a0000000-0000-0000-0000-0000000000E0','a0000000-0000-0000-0000-000000000062',2,'a0000000-0000-0000-0000-000000000042',1,3)
ON CONFLICT (id) DO NOTHING;

INSERT INTO bom_operations (id, bom_id, work_center_id, name, duration_hours, sort_order) VALUES
('a0000000-0000-0000-0000-0000000000E4','a0000000-0000-0000-0000-0000000000E0','a0000000-0000-0000-0000-0000000000D0','Mélange',2,1),
('a0000000-0000-0000-0000-0000000000E5','a0000000-0000-0000-0000-0000000000E0','a0000000-0000-0000-0000-0000000000D1','Cuisson',1.5,2)
ON CONFLICT (id) DO NOTHING;

INSERT INTO manufacturing_orders (id, company_id, number, bom_id, product_id, warehouse_id, planned_qty, produced_qty, status, planned_start, planned_end, actual_start, actual_end, material_cost, labor_cost, overhead_cost, notes, journal_entry_id, created_by, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-0000000000F0','00000000-0000-0000-0000-000000000002','OF-2025-0001','a0000000-0000-0000-0000-0000000000E0','a0000000-0000-0000-0000-000000000063','00000000-0000-0000-0000-000000000010',1000,1000,'completed','2025-06-10','2025-06-12','2025-06-10','2025-06-12',36000,10500,4000,'Production biscuits',NULL,'00000000-0000-0000-0000-000000000003',now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO mo_component_lines (id, mo_id, component_id, required_qty, consumed_qty, unit_cost) VALUES
('a0000000-0000-0000-0000-0000000000F1','a0000000-0000-0000-0000-0000000000F0','a0000000-0000-0000-0000-000000000060',50,50,2500),
('a0000000-0000-0000-0000-0000000000F2','a0000000-0000-0000-0000-0000000000F0','a0000000-0000-0000-0000-000000000061',30,30,4500),
('a0000000-0000-0000-0000-0000000000F3','a0000000-0000-0000-0000-0000000000F0','a0000000-0000-0000-0000-000000000062',20,20,6800)
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 8. PROJECTS
-- ---------------------------------------------------------------------------

INSERT INTO project_tasks (id, project_id, parent_id, title, description, assignee_id, status, priority, estimated_hours, actual_hours, due_date, completed_at, sort_order, created_at, updated_at, color, tags, start_date) VALUES
('a0000000-0000-0000-0000-000000000830','2cbc2a09-da4e-4780-8f1c-6e366ecd4681',NULL,'Cahier des charges','Rédaction du cahier des charges','a0000000-0000-0000-0000-000000000032','done','high',20,18,'2025-05-30','2025-05-28',1,now(),now(),'green',ARRAY['planning'],'2025-05-15'),
('a0000000-0000-0000-0000-000000000831','2cbc2a09-da4e-4780-8f1c-6e366ecd4681',NULL,'Maquettes UI','Design des maquettes','a0000000-0000-0000-0000-000000000032','in_progress','medium',40,25,'2025-07-15',NULL,2,now(),now(),'blue',ARRAY['design'],'2025-06-01'),
('a0000000-0000-0000-0000-000000000832','2cbc2a09-da4e-4780-8f1c-6e366ecd4681',NULL,'Développement','Développement des modules','a0000000-0000-0000-0000-000000000031','todo','high',120,0,'2025-09-30',NULL,3,now(),now(),'orange',ARRAY['dev'],'2025-07-01')
ON CONFLICT (id) DO NOTHING;

INSERT INTO project_milestones (id, project_id, title, description, due_date, completed_at, status, owner_id, progress_pct, sort_order, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000840','2cbc2a09-da4e-4780-8f1c-6e366ecd4681','Validation cahier des charges','Validation par le client','2025-05-30','2025-05-28','completed','a0000000-0000-0000-0000-000000000032',100,1,now(),now()),
('a0000000-0000-0000-0000-000000000841','2cbc2a09-da4e-4780-8f1c-6e366ecd4681','Recette finale','Recette et livraison','2025-10-15',NULL,'pending','a0000000-0000-0000-0000-000000000032',0,2,now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO project_expenses (id, project_id, task_id, employee_id, company_id, category, description, amount, currency, expense_date, receipt_url, status, approved_by, approved_at, rejection_note, is_billable, billed, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000850','2cbc2a09-da4e-4780-8f1c-6e366ecd4681','a0000000-0000-0000-0000-000000000831','a0000000-0000-0000-0000-000000000032','00000000-0000-0000-0000-000000000002','software','Licence Figma',1500,'DZD','2025-06-05','','approved','00000000-0000-0000-0000-000000000003',now(),NULL,false,false,now(),now())
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 9. FLEET
-- ---------------------------------------------------------------------------

INSERT INTO fleet_drivers (id, company_id, employee_id, first_name, last_name, phone, email, national_id, license_number, license_class, license_expiry, license_issue_date, status, hire_date, address, emergency_contact, emergency_phone, notes, photo_url, is_active, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000110','00000000-0000-0000-0000-000000000002',NULL,'Tarek','Bouzid','0557 22 33 44','tarek.bouzid@example.com','1991230456789','LIC-001','B','2027-06-01','2022-06-01','active','2022-06-15','Bab Ezzouar','Ahmed Bouzid','0558 99 88 77','Chauffeur interne','',true,now(),now()),
('a0000000-0000-0000-0000-000000000111','00000000-0000-0000-0000-000000000002',NULL,'Rachid','Amrani','0559 66 55 44','rachid.amrani@example.com','1988230789012','LIC-002','C1','2026-11-01','2021-11-01','active','2021-11-15','Dar El Beida','Salim Amrani','0560 33 22 11','Chauffeur commercial','',true,now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO fleet_vehicles (id, company_id, plate_number, vin, make, model, year, color, vehicle_type, fuel_type, status, odometer_km, fuel_tank_capacity, seating_capacity, purchase_date, purchase_price, current_value, insurance_policy, insurance_expiry, registration_expiry, technical_visit_expiry, assigned_driver_id, department, notes, image_url, is_active, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000100','00000000-0000-0000-0000-000000000002','16 1234 567','WVWZZZ1JZXW000001','Volkswagen','Caddy',2020,'Blanc','van','diesel','active',85000,55,5,'2023-01-15',4200000,3200000,'POL-2023-001','2026-01-15','2026-03-01','2025-12-01','a0000000-0000-0000-0000-000000000110','PROD','Véhicule de liaison','',true,now(),now()),
('a0000000-0000-0000-0000-000000000101','00000000-0000-0000-0000-000000000002','31 5678 901','VF1FL5B0240000002','Renault','Kangoo',2021,'Gris','van','diesel','active',52000,50,5,'2023-05-20',3800000,2950000,'POL-2023-002','2027-05-20','2026-09-01','2026-01-15','a0000000-0000-0000-0000-000000000111','SALES','Véhicule commercial','',true,now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO fleet_fuel_logs (id, company_id, vehicle_id, driver_id, log_date, odometer_km, liters, price_per_liter, fuel_type, station_name, full_tank, notes, is_active, created_at, updated_at, fill_date, mileage_at_fill, fuel_station, is_full_tank) VALUES
('a0000000-0000-0000-0000-000000000120','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000100','a0000000-0000-0000-0000-000000000110','2025-06-10',84300,40,24.5,'diesel','Naftal Rouiba',true,'',true,now(),now(),'2025-06-10',84300,'Naftal Rouiba',true),
('a0000000-0000-0000-0000-000000000121','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000101','a0000000-0000-0000-0000-000000000111','2025-06-12',50800,35,24.5,'diesel','Naftal Dar El Beida',true,'',true,now(),now(),'2025-06-12',50800,'Naftal Dar El Beida',true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO fleet_maintenance (id, company_id, vehicle_id, title, description, maintenance_type, status, scheduled_date, completed_date, odometer_km, next_service_km, next_service_date, technician, garage_name, labor_cost, parts_cost, total_cost, work_performed, notes, is_active, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000122','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000100','Vidange périodique','Vidange et filtres','preventive','completed','2025-05-20','2025-05-20',84000,89000,'2025-08-20','Karim','Garage Central',3000,8500,11500,'Vidange, filtre à huile, filtre à air','',true,now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO fleet_assignments (id, company_id, vehicle_id, driver_id, start_date, end_date, start_odometer, end_odometer, purpose, destination, notes, status, is_active, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000123','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000100','a0000000-0000-0000-0000-000000000110','2025-06-15','2025-06-19',84800,85050,'Livraison marchandises','Oran','Livraison hebdomadaire','completed',true,now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO fleet_expenses (id, company_id, vehicle_id, driver_id, expense_type, expense_date, amount, description, reference_number, notes, is_active, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000124','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000100','a0000000-0000-0000-0000-000000000110','insurance','2025-01-15',12000,'Assurance annuelle','ASS-2025-01','','true',now(),now())
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 10. QUALITY
-- ---------------------------------------------------------------------------

INSERT INTO quality_control_plans (id, company_id, code, name, description, version, item_id, item_category_id, applies_to, is_active, created_by, approved_by, approved_at, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000130','00000000-0000-0000-0000-000000000002','QCP-001','Plan contrôle biscuits','Contrôle qualité des biscuits sablés','V1','a0000000-0000-0000-0000-000000000063','a0000000-0000-0000-0000-000000000051','item',true,'00000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000003',now(),now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO quality_check_templates (id, plan_id, sequence, name, description, check_type, unit, min_value, max_value, norm_reference, is_mandatory, instructions, created_at) VALUES
('a0000000-0000-0000-0000-000000000131','a0000000-0000-0000-0000-000000000130',1,'Poids net','Vérification du poids net','measurement','g',495,505,'Norme interne',true,'Peser 10 paquets',now()),
('a0000000-0000-0000-0000-000000000132','a0000000-0000-0000-0000-000000000130',2,'Aspect visuel','Contrôle visuel','visual','',0,0,'Référence couleur',true,'Inspecter l''apparence',now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO quality_inspections (id, company_id, reference, inspection_type, status, plan_id, item_id, lot_number, qty_to_inspect, qty_passed, qty_failed, overall_result, source_type, source_id, source_ref, scheduled_date, started_at, completed_at, inspector_id, notes, closure_notes, created_by, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000133','00000000-0000-0000-0000-000000000002','CI-2025-0001','final','passed','a0000000-0000-0000-0000-000000000130','a0000000-0000-0000-0000-000000000063','LOT-20250610',200,198,2,'passed','manufacturing_order','a0000000-0000-0000-0000-0000000000F0','OF-2025-0001','2025-06-12','2025-06-12','2025-06-12','00000000-0000-0000-0000-000000000003','Conforme','','00000000-0000-0000-0000-000000000003',now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO quality_checks (id, inspection_id, template_id, sequence, name, description, check_type, unit, min_value, max_value, norm_reference, instructions, is_mandatory, result, measured_value, notes, checked_by, checked_at, created_at) VALUES
('a0000000-0000-0000-0000-000000000134','a0000000-0000-0000-0000-000000000133','a0000000-0000-0000-0000-000000000131',1,'Poids net','Vérification du poids net','measurement','g',495,505,'Norme interne','Peser 10 paquets',true,'pass',501,'OK','00000000-0000-0000-0000-000000000003',now(),now()),
('a0000000-0000-0000-0000-000000000135','a0000000-0000-0000-0000-000000000133','a0000000-0000-0000-0000-000000000132',2,'Aspect visuel','Contrôle visuel','visual','',0,0,'Référence couleur','Inspecter l''apparence',true,'pass',0,'OK','00000000-0000-0000-0000-000000000003',now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO non_conformities (id, company_id, reference, title, description, status, severity, source_type, source_id, source_ref, inspection_id, item_id, lot_number, qty_affected, department_id, process, detected_by, detected_date, assigned_to, target_date, closed_date, root_cause, immediate_action, closure_notes, created_by, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000140','00000000-0000-0000-0000-000000000002','NC-2025-0001','Poids hors tolérance','2 paquets hors tolérance de poids','closed','minor','inspection','a0000000-0000-0000-0000-000000000133','CI-2025-0001','a0000000-0000-0000-0000-000000000133','a0000000-0000-0000-0000-000000000063','LOT-20250610',2,'a0000000-0000-0000-0000-000000000010','conditionnement','00000000-0000-0000-0000-000000000003','2025-06-12','00000000-0000-0000-0000-000000000003','2025-06-20','2025-06-18','Réglage doseuse','Mise en quarantaine','Calibrage effectué','00000000-0000-0000-0000-000000000003',now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO corrective_actions (id, company_id, reference, title, description, ca_type, status, priority, nc_id, root_cause, root_cause_method, proposed_action, implemented_action, responsible_id, department_id, due_date, implementation_date, verified_by, verified_date, effectiveness_rating, effectiveness_notes, estimated_cost, actual_cost, closed_date, created_by, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000150','00000000-0000-0000-0000-000000000002','AC-2025-0001','Calibrage doseuse','Action corrective suite NC-2025-0001','corrective','verified','high','a0000000-0000-0000-0000-000000000140','Dérive du réglage','5why','Calibrer la doseuse hebdomadairement','Calibrage réalisé','00000000-0000-0000-0000-000000000003','a0000000-0000-0000-0000-000000000010','2025-06-20','2025-06-18','00000000-0000-0000-0000-000000000003','2025-06-20',4,'Efficace',5000,3500,'2025-06-20','00000000-0000-0000-0000-000000000003',now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO ca_tasks (id, ca_id, title, description, assigned_to, due_date, completed_date, status, notes, created_at) VALUES
('a0000000-0000-0000-0000-000000000160','a0000000-0000-0000-0000-000000000150','Calibrer la doseuse','Réaliser le calibrage','00000000-0000-0000-0000-000000000003','2025-06-18','2025-06-18','completed','Fait',now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO quality_metrics (id, company_id, metric_date, metric_type, value, notes, created_at) VALUES
('a0000000-0000-0000-0000-000000000161','00000000-0000-0000-0000-000000000002','2025-06-30','first_pass_yield',98.5,'Rendement du premier passage',now()),
('a0000000-0000-0000-0000-000000000162','00000000-0000-0000-0000-000000000002','2025-06-30','defect_rate',0.8,'Taux de défauts',now())
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 11. HELPDESK
-- ---------------------------------------------------------------------------

INSERT INTO helpdesk_categories (id, company_id, name, description, parent_id, color, is_active, sort_order, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000170','00000000-0000-0000-0000-000000000002','Informatique','Problèmes informatiques',NULL,'blue',true,1,now(),now()),
('a0000000-0000-0000-0000-000000000171','00000000-0000-0000-0000-000000000002','Comptabilité','Problèmes comptables',NULL,'green',true,2,now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO helpdesk_agents (id, company_id, user_id, name, email, phone, department, specialization, status, max_tickets, is_active, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000180','00000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000003','Mounir Abderrahmani','admin@mab-erp.dz','0555 00 00 00','IT','ERP', 'active',50,true,now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO helpdesk_sla_policies (id, company_id, name, description, priority, first_response_hours, resolution_hours, business_hours_only, is_active, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000190','00000000-0000-0000-0000-000000000002','SLA Standard','Réponse sous 8h, résolution sous 48h','medium',8,48,true,true,now(),now()),
('a0000000-0000-0000-0000-000000000191','00000000-0000-0000-0000-000000000002','SLA Critique','Réponse sous 1h, résolution sous 24h','critical',1,24,false,true,now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO helpdesk_tickets (id, company_id, ticket_number, subject, description, status, priority, source, category_id, sla_policy_id, assigned_agent_id, requester_name, requester_email, requester_phone, company_name, first_response_at, resolved_at, closed_at, due_date, tags, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-0000000001A0','00000000-0000-0000-0000-000000000002','TKT-2025-0001','Imprimante en panne','L''imprimante du service comptabilité ne fonctionne plus','resolved','high','portal','a0000000-0000-0000-0000-000000000170','a0000000-0000-0000-0000-000000000190','a0000000-0000-0000-0000-000000000180','Fatima Zahra Benali','fatima.benali@example.com','0550 12 34 56','MAB ERP','2025-06-18','2025-06-19','2025-06-19','2025-06-20',ARRAY['printing'],now(),now()),
('a0000000-0000-0000-0000-0000000001A1','00000000-0000-0000-0000-000000000002','TKT-2025-0002','Demande d''accès module stocks','Besoin d''un accès au module stocks','open','medium','email','a0000000-0000-0000-0000-000000000170',NULL,NULL,'Karim Haddad','karim.haddad@example.com','0551 98 76 54','MAB ERP',NULL,NULL,NULL,'2025-06-25',ARRAY['access'],now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO ticket_comments (id, company_id, ticket_id, agent_id, author_name, body, is_internal, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-0000000001B0','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-0000000001A0','a0000000-0000-0000-0000-000000000180','Mounir Abderrahmani','Cartouche de toner remplacée, test d''impression OK',false,now(),now())
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 12. FIXED ASSETS
-- ---------------------------------------------------------------------------

INSERT INTO fixed_assets (id, company_id, asset_number, name, description, category_id, location_id, status, condition, serial_number, barcode, brand, model, supplier, purchase_date, purchase_cost, salvage_value, useful_life_years, depreciation_method, depreciation_rate, accumulated_depreciation, depreciation_start, last_depreciation_date, disposal_date, disposal_value, disposal_reason, assigned_to, warranty_expiry, insurance_policy, insurance_expiry, notes, tags, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000200','00000000-0000-0000-0000-000000000002','ACT-2025-0001','Four rotatif','Four de cuisson industriel','826894db-5d60-487f-b0e6-24a1d759d517','fc360704-2a8a-4396-b39e-26ab5699b59c','in_use','good','SR-8890','BAR-0001','Fimar','FT60','Sarl Blé d''Or','2024-03-15',2500000,250000,10,'straight_line',10,125000,'2024-04-01','2025-06-30',NULL,0,'','Mounir Abderrahmani','2027-03-15','INS-2024-01','2025-03-15','Four principal',ARRAY['furnace'],now(),now()),
('a0000000-0000-0000-0000-000000000201','00000000-0000-0000-0000-000000000002','ACT-2025-0002','Doseuse automatique','Doseuse pour conditionnement','826894db-5d60-487f-b0e6-24a1d759d517','fc360704-2a8a-4396-b39e-26ab5699b59c','in_use','good','DS-1122','BAR-0002','Tecnopool','DP-50','Eurl SucrePlus','2024-06-10',1800000,180000,8,'straight_line',12.5,150000,'2024-07-01','2025-06-30',NULL,0,'','Mounir Abderrahmani','2026-06-10','INS-2024-02','2025-06-10','Doseuse atelier',ARRAY['packaging'],now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO asset_depreciation_schedules (id, company_id, asset_id, period_year, period_month, period_label, opening_book_value, depreciation_amount, accumulated_depreciation, closing_book_value, is_posted, posted_at, created_at) VALUES
('a0000000-0000-0000-0000-000000000210','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000200',2025,6,'2025-06',2500000,20833,145833,2354167,true,now(),now()),
('a0000000-0000-0000-0000-000000000211','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000201',2025,6,'2025-06',1800000,18750,168750,1631250,true,now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO asset_maintenance_records (id, company_id, asset_id, maintenance_type, status, title, description, scheduled_date, started_at, completed_at, performed_by, vendor, cost, downtime_hours, next_maintenance_date, findings, actions_taken, parts_replaced, warranty_claim, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000212','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000200','preventive','completed','Maintenance four','Visite de maintenance trimestrielle','2025-04-15','2025-04-15','2025-04-15','Karim','Garage Central',8000,3,'2025-07-15','Aucune anomalie','Graissage et nettoyage','','false',now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO asset_transfers (id, company_id, transfer_number, asset_id, from_location_id, to_location_id, from_custodian, to_custodian, transfer_date, reason, status, approved_by, approved_at, completed_at, notes, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000213','00000000-0000-0000-0000-000000000002','TRF-2025-0001','a0000000-0000-0000-0000-000000000200',NULL,NULL,'','','2025-06-25','Rorganisation atelier','approved','00000000-0000-0000-0000-000000000003',now(),NULL,'À compléter',now(),now())
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 13. BUDGETING
-- ---------------------------------------------------------------------------

INSERT INTO budget_categories (id, company_id, code, name, description, parent_id, is_active, sort_order, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000301','00000000-0000-0000-0000-000000000002','OP','Opérationnel','Dépenses opérationnelles',NULL,true,1,now(),now()),
('a0000000-0000-0000-0000-000000000302','00000000-0000-0000-0000-000000000002','CAP','Capital','Investissements',NULL,true,2,now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO annual_budgets (id, company_id, budget_number, fiscal_year, name, description, budget_type, status, start_date, end_date, total_amount, approved_by, approved_at, notes, created_by, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000300','00000000-0000-0000-0000-000000000002','BDG-2025-01','2025','Budget annuel 2025','Budget de fonctionnement 2025','operational','active','2025-01-01','2025-12-31',12000000,'00000000-0000-0000-0000-000000000003',now(),'Budget approuvé','00000000-0000-0000-0000-000000000003',now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO department_budgets (id, company_id, annual_budget_id, department_id, department_name, department_code, allocated_amount, spent_amount, committed_amount, notes, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000310','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000300','a0000000-0000-0000-0000-000000000010','Production','PROD',5000000,1500000,0,'',now(),now()),
('a0000000-0000-0000-0000-000000000311','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000300','a0000000-0000-0000-0000-000000000013','Finance','FIN',2000000,400000,0,'',now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO budget_line_items (id, company_id, annual_budget_id, department_budget_id, category_id, account_code, account_name, description, budget_amount, q1_amount, q2_amount, q3_amount, q4_amount, actual_amount, committed_amount, notes, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000320','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000300','a0000000-0000-0000-0000-000000000310','a0000000-0000-0000-0000-000000000301','60','Achats consommés','Matières premières',3000000,750000,750000,750000,750000,297500,0,'',now(),now()),
('a0000000-0000-0000-0000-000000000321','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000300','a0000000-0000-0000-0000-000000000311','a0000000-0000-0000-0000-000000000301','61','Services extérieurs','Frais généraux',1500000,375000,375000,375000,375000,400000,0,'',now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO budget_commitments (id, company_id, commitment_number, annual_budget_id, department_budget_id, line_item_id, commitment_type, status, reference_number, vendor_name, description, committed_amount, fulfilled_amount, commitment_date, expected_fulfillment, approved_by, approved_at, notes, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000330','00000000-0000-0000-0000-000000000002','CMT-2025-0001','a0000000-0000-0000-0000-000000000300','a0000000-0000-0000-0000-000000000310','a0000000-0000-0000-0000-000000000320','purchase_order','approved','BC-2025-0001','Sarl Blé d''Or','Commande farine',297500,297500,'2025-06-01','2025-06-16','00000000-0000-0000-0000-000000000003',now(),'',now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO budget_actuals (id, company_id, annual_budget_id, department_budget_id, line_item_id, commitment_id, transaction_date, reference_type, reference_id, reference_number, description, amount, posted, posted_at, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000340','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000300','a0000000-0000-0000-0000-000000000310','a0000000-0000-0000-0000-000000000320','a0000000-0000-0000-0000-000000000330','2025-06-16','purchase_invoice','a0000000-0000-0000-0000-000000000794','FAF-2025-0001','Facture farine',297500,true,now(),now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO budget_revisions (id, company_id, revision_number, annual_budget_id, line_item_id, department_budget_id, revision_type, original_amount, revised_amount, reason, status, requested_by, approved_by, approved_at, effective_date, notes, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000341','00000000-0000-0000-0000-000000000002','REV-2025-0001','a0000000-0000-0000-0000-000000000300','a0000000-0000-0000-0000-000000000320','a0000000-0000-0000-0000-000000000310','increase',3000000,3200000,'Hausse prix matières','active','00000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000003',now(),'2025-07-01','',now(),now())
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 14. MAINTENANCE / EQUIPMENT
-- ---------------------------------------------------------------------------

INSERT INTO equipment (id, company_id, code, name, category, subcategory, location, department, status, purchase_date, purchase_cost, current_value, warranty_expiry, manufacturer, model, serial_number, asset_tag, specifications, last_maintenance_date, next_maintenance_date, maintenance_interval_days, expected_life_years, notes, image_url, is_active, created_by, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000400','00000000-0000-0000-0000-000000000002','EQ-001','Four rotatif','Machine','Four','Atelier 1','Production','active','2024-03-15',2500000,2375000,'2027-03-15','Fimar','FT60','SR-8890','AST-0001','{"power":"230V / 20kW"}','2025-04-15','2025-07-15',90,10,'Four principal','',true,'00000000-0000-0000-0000-000000000003',now(),now()),
('a0000000-0000-0000-0000-000000000401','00000000-0000-0000-0000-000000000002','EQ-002','Convoyeur','Machine','Transport','Atelier 2','Production','active','2024-06-10',950000,880000,'2026-06-10','SIPA','CV-200','SR-1122','AST-0002','{"length":"12m"}','2025-05-20','2025-08-20',90,12,'Convoyeur d''emballage','',true,'00000000-0000-0000-0000-000000000003',now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO preventive_maintenance_plans (id, company_id, equipment_id, name, description, frequency_type, frequency_value, estimated_hours, estimated_cost, tasks, checklist, last_performed, next_due, lead_days, auto_create_order, assigned_to, is_active, created_by, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000410','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000400','Maintenance trimestrielle four','Vérification et nettoyage trimestriel','quarterly',1,4,8000,'["Graissage","Nettoyage","Contrôle thermique"]','["Graissage","Nettoyage","Contrôle thermique"]','2025-04-15','2025-07-15',7,true,'a0000000-0000-0000-0000-000000000023',true,'00000000-0000-0000-0000-000000000003',now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO maintenance_requests (id, company_id, equipment_id, request_number, title, description, priority, status, failure_type, symptoms, requested_by, requested_by_name, assigned_to, assigned_to_name, submitted_at, approved_at, approved_by, completed_at, rejection_reason, estimated_cost, actual_cost, notes, is_active, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000420','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000400','DM-2025-0001','Bruit anormal four','Bruit anormal lors de la rotation','medium','completed','mécanique','Bruit anormal','a0000000-0000-0000-0000-000000000032','Sara Cherif','a0000000-0000-0000-0000-000000000023','Technicien maintenance','2025-06-05','2025-06-06','00000000-0000-0000-0000-000000000003','2025-06-07',NULL,5000,4500,'Roulement remplacé',true,now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO maintenance_orders (id, company_id, request_id, equipment_id, order_number, order_type, status, priority, title, description, work_performed, findings, assigned_technician, team_members, planned_start_date, planned_end_date, actual_start_date, actual_end_date, estimated_hours, actual_hours, labor_cost, parts_cost, other_cost, total_cost, next_service_date, color, is_active, created_by, completed_by, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000430','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000420','a0000000-0000-0000-0000-000000000400','OT-2025-0001','corrective','completed','medium','Remplacement roulement','Suite DM-2025-0001','Roulement remplacé','Roulement usé','Karim','["Karim","Rachid"]','2025-06-06','2025-06-07','2025-06-06','2025-06-07',6,5,2000,2500,0,4500,'2025-07-15','green',true,'00000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000003',now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO maintenance_history (id, company_id, equipment_id, order_id, history_type, title, description, work_performed, findings, technician_name, performed_date, duration_hours, downtime_hours, labor_cost, parts_cost, other_cost, total_cost, next_service_date, is_active, created_by, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000440','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000400','a0000000-0000-0000-0000-000000000430','corrective','Remplacement roulement','','Roulement remplacé','Roulement usé','Karim','2025-06-07',5,3,2000,2500,0,4500,'2025-07-15',true,'00000000-0000-0000-0000-000000000003',now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO maintenance_schedule (id, company_id, plan_id, order_id, equipment_id, title, event_type, scheduled_date, end_date, status, color, notes, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000441','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000410','a0000000-0000-0000-0000-000000000430','a0000000-0000-0000-0000-000000000400','Maintenance trimestrielle','preventive','2025-07-15','2025-07-15','scheduled','blue','Plan trimestriel',now(),now())
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 15. HR
-- ---------------------------------------------------------------------------

INSERT INTO leave_requests (id, company_id, employee_id, leave_type_id, start_date, end_date, days_count, reason, status, approved_by, approved_at, rejection_reason, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000500','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000030','e8569f94-cf59-468e-94d7-99aac165a7a6','2025-07-14','2025-07-18',5,'Congé annuel','approved','00000000-0000-0000-0000-000000000003',now(),NULL,now(),now()),
('a0000000-0000-0000-0000-000000000501','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000031','72fa5f13-d227-4752-86a2-b73b4098e1be','2025-06-23','2025-06-24',2,'Maladie','pending',NULL,NULL,NULL,now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO timesheets (id, company_id, employee_id, project_id, task_id, date, hours, description, billable, billed, approved, approved_by, created_at, hourly_rate) VALUES
('a0000000-0000-0000-0000-000000000510','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000032','2cbc2a09-da4e-4780-8f1c-6e366ecd4681','a0000000-0000-0000-0000-000000000831','2025-06-10',7,'Conception maquettes',false,false,true,'00000000-0000-0000-0000-000000000003',now(),5000),
('a0000000-0000-0000-0000-000000000511','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000031','2cbc2a09-da4e-4780-8f1c-6e366ecd4681','a0000000-0000-0000-0000-000000000832','2025-06-11',6,'Développement module','false',false,false,NULL,now(),4000)
ON CONFLICT (id) DO NOTHING;

INSERT INTO attendance (id, employee_id, date, check_in, check_out, hours_worked, overtime_hours, status, notes) VALUES
('a0000000-0000-0000-0000-000000000520','a0000000-0000-0000-0000-000000000030','2025-06-16','2025-06-16 08:55:00','2025-06-16 17:05:00',8.2,0,'present',''),
('a0000000-0000-0000-0000-000000000521','a0000000-0000-0000-0000-000000000031','2025-06-16','2025-06-16 09:10:00','2025-06-16 18:00:00',8.8,0.8,'present','')
ON CONFLICT (id) DO NOTHING;

INSERT INTO payroll_runs (id, company_id, period_month, period_year, status, total_gross, total_irg, total_cnas_employee, total_cnas_employer, total_net, total_employees, approved_by, approved_at, paid_at, journal_entry_id, created_by, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000530','00000000-0000-0000-0000-000000000002',6,2025,'paid',430000,15500,38700,106200,352800,4,'00000000-0000-0000-0000-000000000003',now(),now(),NULL,'00000000-0000-0000-0000-000000000003',now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO payslips (id, payroll_run_id, employee_id, period_month, period_year, days_worked, overtime_hours, base_salary, overtime_amount, transport_allowance, meal_allowance, housing_allowance, other_allowances, gross_salary, cnas_employee, cnas_employer, taxable_income, irg_amount, other_deductions, advance_deduction, net_salary, irg_bracket, created_at) VALUES
('a0000000-0000-0000-0000-000000000531','a0000000-0000-0000-0000-000000000530','a0000000-0000-0000-0000-000000000030',6,2025,22,0,95000,0,3000,4000,8000,0,110000,9900,27200,100100,5200,0,0,94900,'{"bracket":"bracket2"}',now()),
('a0000000-0000-0000-0000-000000000532','a0000000-0000-0000-0000-000000000530','a0000000-0000-0000-0000-000000000031',6,2025,22,0,85000,0,3000,4000,8000,0,100000,9000,24700,91000,4300,0,0,86700,'{"bracket":"bracket2"}',now()),
('a0000000-0000-0000-0000-000000000533','a0000000-0000-0000-0000-000000000530','a0000000-0000-0000-0000-000000000032',6,2025,22,0,130000,0,3000,4000,8000,0,145000,13050,35900,131950,6000,0,0,125950,'{"bracket":"bracket2"}',now()),
('a0000000-0000-0000-0000-000000000534','a0000000-0000-0000-0000-000000000530','1a05d22b-713c-48fb-9bea-5c539012a688',6,2025,22,0,75000,0,3000,4000,8000,0,90000,8100,22200,81900,4000,0,0,77900,'{"bracket":"bracket2"}',now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO job_postings (id, company_id, department_id, position_id, title, description, requirements, location, employment_type, vacancies, status, published_at, deadline_date, created_by, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000540','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000011','a0000000-0000-0000-0000-000000000022','Commercial senior','Recherche commercial expérimenté','Bac+3 minimum, 3 ans expérience','Alger','full_time',1,'open','2025-06-01','2025-07-31','00000000-0000-0000-0000-000000000003',now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO job_applications (id, job_posting_id, company_id, first_name, last_name, email, phone, cv_url, cover_letter, source, status, expected_salary, interview_date, interview_notes, rejection_reason, hired_as_employee_id, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000541','a0000000-0000-0000-0000-000000000540','00000000-0000-0000-0000-000000000002','Yasmine','Belkacem','yasmine.belkacem@example.com','0555 66 77 88','','','job_board','interview',90000,'2025-06-20','Bon profil',NULL,NULL,now(),now())
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 16. TAX
-- ---------------------------------------------------------------------------

INSERT INTO tax_declarations (id, company_id, declaration_type, period_type, period_year, period_month, period_quarter, reference, status, tva_collected, tva_deductible, tva_credit_bf, tap_base, tap_rate, tap_reduction, ibs_taxable_income, ibs_rate, ibs_prepayments, stamp_tax_amount, irg_wages_amount, irg_fees_amount, submitted_at, accepted_at, submission_ref, notes, created_by, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000600','00000000-0000-0000-0000-000000000002','tva_return','monthly',2025,6,NULL,'G50-2025-06','submitted',102600,47500,0,0,0,0,0,0,0,0,0,0,'2025-07-20',NULL,'G50-00012345','Déclaration mensuelle','00000000-0000-0000-0000-000000000003',now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO vat_returns (id, company_id, period_year, period_month, declaration_id, sales_base_0, sales_base_9, sales_base_19, sales_vat_9, sales_vat_19, purch_base_9, purch_base_19, purch_vat_9, purch_vat_19, credit_bf, status, notes, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000601','00000000-0000-0000-0000-000000000002',2025,6,'a0000000-0000-0000-0000-000000000600',0,0,540000,0,102600,0,250000,0,47500,0,'submitted','',now(),now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO vat_register (id, company_id, register_type, period_year, period_month, document_date, document_number, document_ref, partner_name, partner_tax_id, taxable_base, vat_rate, vat_amount, total_amount, is_exported, declaration_id, created_at) VALUES
('a0000000-0000-0000-0000-000000000602','00000000-0000-0000-0000-000000000002','sales',2025,6,'2025-06-05','FV-2025-0001',NULL,'Sarl Distribution Algéroise','0999123456789',540000,0.19,102600,642600,false,'a0000000-0000-0000-0000-000000000600',now()),
('a0000000-0000-0000-0000-000000000603','00000000-0000-0000-0000-000000000002','purchase',2025,6,'2025-06-16','FAF-2025-0001',NULL,'Sarl Blé d''Or','0998123456789',250000,0.19,47500,297500,false,'a0000000-0000-0000-0000-000000000600',now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO tax_payments (id, company_id, declaration_id, payment_number, payment_date, due_date, declaration_type, period_year, period_month, period_quarter, amount_due, amount_paid, status, payment_method, bank_account_id, reference, receipt_number, notes, created_at, updated_at) VALUES
('a0000000-0000-0000-0000-000000000610','00000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000600','TP-2025-0001','2025-07-20','2025-07-20','tva_return',2025,6,NULL,55100,0,'pending','bank_transfer','a0000000-0000-0000-0000-0000000000B0','',NULL,NULL,now(),now())
ON CONFLICT (id) DO NOTHING;

COMMIT;