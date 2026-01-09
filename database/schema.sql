-- Clinext Medical Beauty Clinic Database Schema
-- PostgreSQL Version
-- Based on ERD from User/Development/erd.md

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- CORE TABLES
-- =====================================================

-- 患者資料表
CREATE TABLE patients (
    patient_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    full_name VARCHAR(100) NOT NULL,
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    date_of_birth DATE,
    phone VARCHAR(20),
    email VARCHAR(100),
    skin_type VARCHAR(10) CHECK (skin_type IN ('I', 'II', 'III', 'IV', 'V', 'VI')),
    medical_history TEXT,
    allergy_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_patients_phone ON patients(phone);
CREATE INDEX idx_patients_email ON patients(email);

-- 醫師資料表
CREATE TABLE doctors (
    doctor_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    full_name VARCHAR(100) NOT NULL,
    license_no VARCHAR(50) UNIQUE,
    specialty VARCHAR(100),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 護理師/美容師資料表
CREATE TABLE staff (
    staff_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) CHECK (role IN ('nurse', 'therapist', 'consultant', 'admin')),
    license_no VARCHAR(50),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 就診記錄表
CREATE TABLE visits (
    visit_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,
    visit_date DATE NOT NULL,
    visit_type VARCHAR(20) CHECK (visit_type IN ('consultation', 'treatment', 'follow_up')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_visits_patient ON visits(patient_id);
CREATE INDEX idx_visits_date ON visits(visit_date);

-- =====================================================
-- TREATMENT MASTER DATA
-- =====================================================

-- 療程主檔
CREATE TABLE treatments (
    treatment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    treatment_code VARCHAR(50) UNIQUE NOT NULL,
    treatment_name VARCHAR(200) NOT NULL,
    category VARCHAR(50) CHECK (category IN ('injection', 'device', 'laser', 'facial', 'body', 'bundle')),
    default_unit VARCHAR(20),
    base_price DECIMAL(10, 2),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_treatments_category ON treatments(category);
CREATE INDEX idx_treatments_active ON treatments(is_active);

-- 設備資料表
CREATE TABLE devices (
    device_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_name VARCHAR(100) NOT NULL,
    device_type VARCHAR(50) CHECK (device_type IN ('HIFU', 'RF', 'Laser', 'IPL', 'Cryolipolysis', 'Other')),
    manufacturer VARCHAR(100),
    model VARCHAR(100),
    maintenance_cycle_days INTEGER DEFAULT 90,
    last_maintenance_date DATE,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'maintenance', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 藥品/耗材資料表
CREATE TABLE drugs (
    drug_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    drug_code VARCHAR(50) UNIQUE,
    drug_name VARCHAR(200) NOT NULL,
    drug_type VARCHAR(50) CHECK (drug_type IN ('Botox', 'HA', 'PRP', 'Anesthetic', 'Consumable', 'Other')),
    unit VARCHAR(20),
    supplier VARCHAR(100),
    batch_no VARCHAR(50),
    expiry_date DATE,
    stock_quantity DECIMAL(10, 2) DEFAULT 0,
    min_stock_level DECIMAL(10, 2) DEFAULT 0,
    unit_cost DECIMAL(10, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_drugs_expiry ON drugs(expiry_date);
CREATE INDEX idx_drugs_type ON drugs(drug_type);

-- =====================================================
-- TREATMENT SESSION (CLINICAL RECORDS)
-- =====================================================

-- 療程執行記錄
CREATE TABLE treatment_sessions (
    session_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    visit_id UUID NOT NULL REFERENCES visits(visit_id) ON DELETE CASCADE,
    patient_id UUID NOT NULL REFERENCES patients(patient_id),
    treatment_id UUID NOT NULL REFERENCES treatments(treatment_id),
    doctor_id UUID REFERENCES doctors(doctor_id),
    device_id UUID REFERENCES devices(device_id),
    session_no INTEGER DEFAULT 1,
    dosage_value DECIMAL(10, 2),
    dosage_unit VARCHAR(20),
    treatment_area JSONB,
    performed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    immediate_reaction TEXT,
    clinical_notes TEXT,
    status VARCHAR(20) DEFAULT 'completed' CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled')),
    price DECIMAL(10, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sessions_patient ON treatment_sessions(patient_id);
CREATE INDEX idx_sessions_visit ON treatment_sessions(visit_id);
CREATE INDEX idx_sessions_treatment ON treatment_sessions(treatment_id);
CREATE INDEX idx_sessions_date ON treatment_sessions(performed_at);

-- 療程用藥記錄
CREATE TABLE treatment_drug_usage (
    usage_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES treatment_sessions(session_id) ON DELETE CASCADE,
    drug_id UUID NOT NULL REFERENCES drugs(drug_id),
    amount_used DECIMAL(10, 2) NOT NULL,
    unit VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_drug_usage_session ON treatment_drug_usage(session_id);

-- =====================================================
-- FOLLOW-UP & SCHEDULING
-- =====================================================

-- 追蹤/回診記錄
CREATE TABLE follow_ups (
    followup_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,
    session_id UUID REFERENCES treatment_sessions(session_id),
    followup_type VARCHAR(30) CHECK (followup_type IN ('medical', 'maintenance', 'reminder', 'satisfaction')),
    scheduled_date DATE NOT NULL,
    actual_date DATE,
    outcome_notes TEXT,
    next_recommend_date DATE,
    notify_flag BOOLEAN DEFAULT true,
    notification_sent_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'cancelled', 'overdue')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_followups_patient ON follow_ups(patient_id);
CREATE INDEX idx_followups_scheduled ON follow_ups(scheduled_date);
CREATE INDEX idx_followups_status ON follow_ups(status);

-- =====================================================
-- MEDIA & DOCUMENTS
-- =====================================================

-- 媒體檔案 (術前術後照/同意書)
CREATE TABLE media (
    media_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,
    session_id UUID REFERENCES treatment_sessions(session_id),
    media_type VARCHAR(30) CHECK (media_type IN ('before', 'after', 'consent', 'document', 'other')),
    media_url TEXT NOT NULL,
    file_name VARCHAR(255),
    file_size INTEGER,
    mime_type VARCHAR(100),
    captured_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_media_patient ON media(patient_id);
CREATE INDEX idx_media_session ON media(session_id);

-- =====================================================
-- ORDERS & BILLING
-- =====================================================

-- 訂單主表
CREATE TABLE orders (
    order_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_no VARCHAR(50) UNIQUE NOT NULL,
    patient_id UUID NOT NULL REFERENCES patients(patient_id),
    visit_id UUID REFERENCES visits(visit_id),
    doctor_id UUID REFERENCES doctors(doctor_id),
    staff_id UUID REFERENCES staff(staff_id),
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    subtotal DECIMAL(12, 2) DEFAULT 0,
    discount DECIMAL(12, 2) DEFAULT 0,
    tax DECIMAL(12, 2) DEFAULT 0,
    total DECIMAL(12, 2) DEFAULT 0,
    payment_method VARCHAR(30) CHECK (payment_method IN ('cash', 'credit_card', 'debit_card', 'transfer', 'installment', 'voucher')),
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'partial', 'paid', 'refunded')),
    status VARCHAR(20) DEFAULT 'new' CHECK (status IN ('new', 'in_progress', 'completed', 'cancelled')),
    priority VARCHAR(10) DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_orders_patient ON orders(patient_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(status);

-- 訂單明細
CREATE TABLE order_items (
    item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    treatment_id UUID REFERENCES treatments(treatment_id),
    session_id UUID REFERENCES treatment_sessions(session_id),
    item_name VARCHAR(200) NOT NULL,
    quantity INTEGER DEFAULT 1,
    unit_price DECIMAL(10, 2),
    discount DECIMAL(10, 2) DEFAULT 0,
    total DECIMAL(10, 2),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_order_items_order ON order_items(order_id);

-- =====================================================
-- INVENTORY MANAGEMENT
-- =====================================================

-- 庫存異動記錄
CREATE TABLE inventory_transactions (
    transaction_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    drug_id UUID NOT NULL REFERENCES drugs(drug_id),
    transaction_type VARCHAR(20) CHECK (transaction_type IN ('purchase', 'usage', 'adjustment', 'expired', 'return')),
    quantity DECIMAL(10, 2) NOT NULL,
    unit VARCHAR(20),
    reference_id UUID,
    reference_type VARCHAR(50),
    notes TEXT,
    performed_by UUID REFERENCES staff(staff_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_inventory_drug ON inventory_transactions(drug_id);
CREATE INDEX idx_inventory_date ON inventory_transactions(created_at);

-- 採購單
CREATE TABLE purchase_orders (
    po_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    po_no VARCHAR(50) UNIQUE NOT NULL,
    supplier VARCHAR(200),
    order_date DATE NOT NULL,
    expected_date DATE,
    received_date DATE,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'ordered', 'partial', 'received', 'cancelled')),
    total_amount DECIMAL(12, 2),
    notes TEXT,
    created_by UUID REFERENCES staff(staff_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 採購單明細
CREATE TABLE purchase_order_items (
    poi_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    po_id UUID NOT NULL REFERENCES purchase_orders(po_id) ON DELETE CASCADE,
    drug_id UUID NOT NULL REFERENCES drugs(drug_id),
    quantity DECIMAL(10, 2) NOT NULL,
    unit VARCHAR(20),
    unit_cost DECIMAL(10, 2),
    total_cost DECIMAL(10, 2),
    received_quantity DECIMAL(10, 2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- ACCOUNTING / VOUCHERS
-- =====================================================

-- 傳票主表
CREATE TABLE vouchers (
    voucher_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    voucher_no VARCHAR(50) UNIQUE NOT NULL,
    voucher_date DATE NOT NULL,
    voucher_type VARCHAR(20) CHECK (voucher_type IN ('income', 'expense', 'adjustment', 'transfer')),
    description TEXT,
    total_amount DECIMAL(12, 2),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'posted', 'cancelled')),
    reference_type VARCHAR(50),
    reference_id UUID,
    created_by UUID REFERENCES staff(staff_id),
    approved_by UUID REFERENCES staff(staff_id),
    approved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_vouchers_date ON vouchers(voucher_date);
CREATE INDEX idx_vouchers_type ON vouchers(voucher_type);
CREATE INDEX idx_vouchers_status ON vouchers(status);

-- 傳票明細
CREATE TABLE voucher_items (
    vi_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    voucher_id UUID NOT NULL REFERENCES vouchers(voucher_id) ON DELETE CASCADE,
    account_code VARCHAR(20) NOT NULL,
    account_name VARCHAR(100),
    debit_amount DECIMAL(12, 2) DEFAULT 0,
    credit_amount DECIMAL(12, 2) DEFAULT 0,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_voucher_items_voucher ON voucher_items(voucher_id);

-- =====================================================
-- AUTHENTICATION & AUTHORIZATION
-- =====================================================

-- 使用者帳號
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    user_type VARCHAR(20) CHECK (user_type IN ('patient', 'staff', 'admin')),
    patient_id UUID REFERENCES patients(patient_id),
    staff_id UUID REFERENCES staff(staff_id),
    doctor_id UUID REFERENCES doctors(doctor_id),
    is_active BOOLEAN DEFAULT true,
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_type ON users(user_type);

-- 使用者權限
CREATE TABLE user_permissions (
    permission_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    permission_code VARCHAR(50) NOT NULL,
    granted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    granted_by UUID REFERENCES users(user_id)
);

CREATE INDEX idx_permissions_user ON user_permissions(user_id);

-- =====================================================
-- SYSTEM & AUDIT
-- =====================================================

-- 系統設定
CREATE TABLE system_settings (
    setting_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    setting_type VARCHAR(20) DEFAULT 'string',
    description TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(user_id)
);

-- 審計日誌
CREATE TABLE audit_logs (
    log_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(user_id),
    action VARCHAR(50) NOT NULL,
    table_name VARCHAR(50),
    record_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address VARCHAR(50),
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_user ON audit_logs(user_id);
CREATE INDEX idx_audit_table ON audit_logs(table_name);
CREATE INDEX idx_audit_date ON audit_logs(created_at);

-- =====================================================
-- FUNCTIONS & TRIGGERS
-- =====================================================

-- 自動更新 updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_patients_updated_at
    BEFORE UPDATE ON patients
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 訂單編號生成函數
CREATE OR REPLACE FUNCTION generate_order_no()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.order_no IS NULL THEN
        NEW.order_no := 'ORD-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' || 
                        LPAD(NEXTVAL('order_no_seq')::TEXT, 3, '0');
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE SEQUENCE IF NOT EXISTS order_no_seq START 1;

CREATE TRIGGER set_order_no
    BEFORE INSERT ON orders
    FOR EACH ROW
    EXECUTE FUNCTION generate_order_no();

-- =====================================================
-- SAMPLE DATA FOR TESTING
-- =====================================================

-- 插入測試療程資料
INSERT INTO treatments (treatment_code, treatment_name, category, default_unit, base_price, description) VALUES
('BOT_MASSETER', '美國肉毒瘦小臉', 'injection', 'U', 4999, '肉毒桿菌咬肌注射'),
('BOT_FOREHEAD', '肉毒抬頭紋', 'injection', 'U', 3500, '肉毒桿菌額頭注射'),
('BOT_CROW', '肉毒魚尾紋', 'injection', 'U', 2500, '肉毒桿菌眼周注射'),
('HA_NOSE', '玻尿酸隆鼻', 'injection', 'cc', 15000, '玻尿酸鼻部填充'),
('HA_CHIN', '玻尿酸墊下巴', 'injection', 'cc', 12000, '玻尿酸下巴填充'),
('HA_TEAR', '玻尿酸淚溝', 'injection', 'cc', 18000, '玻尿酸淚溝填充'),
('HIFU_FULL', '海芙音波全臉', 'device', 'lines', 38000, '高能聚焦超音波全臉拉提'),
('HIFU_NECK', '海芙音波頸部', 'device', 'lines', 25000, '高能聚焦超音波頸部拉提'),
('THERMAGE_EYE', '鳳凰電波眼周', 'device', 'shots', 45000, '單極射頻眼周緊緻'),
('THERMAGE_FULL', '鳳凰電波全臉', 'device', 'shots', 120000, '單極射頻全臉緊緻'),
('PICO_SPOT', '皮秒雷射除斑', 'laser', 'session', 8000, '皮秒雷射色素斑治療'),
('PICO_TONING', '皮秒雷射淨膚', 'laser', 'session', 5000, '皮秒雷射膚色調理'),
('PRP_FACE', 'PRP自體血清注射', 'injection', 'cc', 25000, 'PRP全臉回春注射');

-- 插入測試藥品資料
INSERT INTO drugs (drug_code, drug_name, drug_type, unit, supplier, stock_quantity, min_stock_level) VALUES
('BOTOX_US', '美國肉毒桿菌 Botox', 'Botox', 'U', 'Allergan', 500, 100),
('BOTOX_KR', '韓國肉毒桿菌 Nabota', 'Botox', 'U', 'Daewoong', 300, 50),
('HA_JUVEDERM', '喬雅登玻尿酸', 'HA', 'cc', 'Allergan', 50, 10),
('HA_RESTYLANE', '瑞絲朗玻尿酸', 'HA', 'cc', 'Galderma', 40, 10),
('LIDO_2', '2% Lidocaine', 'Anesthetic', 'ml', 'Local Supplier', 200, 50),
('NEEDLE_30G', '30G 針頭', 'Consumable', 'pcs', 'BD', 500, 100),
('NEEDLE_27G', '27G 針頭', 'Consumable', 'pcs', 'BD', 500, 100);

-- 插入測試設備資料
INSERT INTO devices (device_name, device_type, manufacturer, model, maintenance_cycle_days) VALUES
('Ulthera 第三代音波', 'HIFU', 'Ulthera', 'DeepSee', 180),
('Thermage FLX', 'RF', 'Solta Medical', 'FLX', 365),
('PicoSure', 'Laser', 'Cynosure', 'PicoSure Pro', 90),
('Fotona', 'Laser', 'Fotona', 'StarWalker', 90);
