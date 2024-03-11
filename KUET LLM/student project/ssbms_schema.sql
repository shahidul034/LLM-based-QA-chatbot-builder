--
-- PostgreSQL database dump
--

-- Dumped from database version 16.1 (Debian 16.1-1.pgdg120+1)
-- Dumped by pg_dump version 16.1 (Debian 16.1-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: addresses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.addresses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    short_address character varying(8),
    building_number integer NOT NULL,
    street_name character varying(255) NOT NULL,
    district_name character varying(255) NOT NULL,
    city_name character varying(255) NOT NULL,
    zip_code integer NOT NULL,
    additional_number integer NOT NULL,
    unit_number integer NOT NULL,
    created_by uuid NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT addresses_additional_number_check CHECK ((additional_number > 0)),
    CONSTRAINT addresses_building_number_check CHECK ((building_number > 0)),
    CONSTRAINT addresses_unit_number_check CHECK ((unit_number > 0)),
    CONSTRAINT addresses_zip_code_check CHECK ((zip_code > 0))
);


ALTER TABLE public.addresses OWNER TO postgres;

--
-- Name: alarms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alarms (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    content character varying(1000) NOT NULL,
    minimum_value bigint NOT NULL,
    maximum_value bigint NOT NULL,
    time_frame bigint NOT NULL,
    type_id uuid NOT NULL,
    severity_id uuid NOT NULL,
    variable_id bigint NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL,
    CONSTRAINT alarms_time_frame_check CHECK ((time_frame >= 0))
);


ALTER TABLE public.alarms OWNER TO postgres;

--
-- Name: alarms_severities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alarms_severities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL
);


ALTER TABLE public.alarms_severities OWNER TO postgres;

--
-- Name: alarms_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alarms_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.alarms_types OWNER TO postgres;

--
-- Name: consumption_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.consumption_categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    facility_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    maximum_kwh integer NOT NULL,
    minimum_kwh integer NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_by uuid NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT consumption_categories_maximum_kwh_check CHECK ((maximum_kwh > 0)),
    CONSTRAINT consumption_categories_minimum_kwh_check CHECK ((minimum_kwh > 0))
);


ALTER TABLE public.consumption_categories OWNER TO postgres;

--
-- Name: consumption_categories_grid_billing_accounts_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.consumption_categories_grid_billing_accounts_types (
    consumption_category_id uuid NOT NULL,
    grid_billing_account_type_id uuid NOT NULL,
    fee_per_kwh numeric(16,8) NOT NULL,
    created_by uuid NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.consumption_categories_grid_billing_accounts_types OWNER TO postgres;

--
-- Name: contacts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contacts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    facility_id uuid NOT NULL,
    title_id uuid NOT NULL,
    first_name character varying(255) NOT NULL,
    middle_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    phone_number character varying(255) NOT NULL,
    job_title character varying(255) NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL,
    preference_during_business_hours boolean DEFAULT false NOT NULL,
    preference_outside_business_hours boolean DEFAULT false NOT NULL,
    preference_on_official_holidays boolean DEFAULT false NOT NULL,
    preference_any_time boolean DEFAULT false NOT NULL
);


ALTER TABLE public.contacts OWNER TO postgres;

--
-- Name: contacts_titles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contacts_titles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    facility_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.contacts_titles OWNER TO postgres;

--
-- Name: device; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.device (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    active boolean,
    gateway_id uuid,
    label character varying(255) NOT NULL,
    user_conf json,
    description character varying(255),
    type_id uuid NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL,
    unit_id uuid,
    facility_id uuid
);


ALTER TABLE public.device OWNER TO postgres;

--
-- Name: device_control_type_icon; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.device_control_type_icon (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    filename character varying(100) NOT NULL,
    ext character varying(10) NOT NULL,
    created_by uuid NOT NULL
);


ALTER TABLE public.device_control_type_icon OWNER TO postgres;

--
-- Name: device_control_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.device_control_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.device_control_types OWNER TO postgres;

--
-- Name: device_controls; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.device_controls (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    device_id uuid NOT NULL,
    unit_id uuid NOT NULL,
    config json NOT NULL,
    created_by uuid NOT NULL,
    icon character varying(50)
);


ALTER TABLE public.device_controls OWNER TO postgres;

--
-- Name: device_controls_unit_pinned; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.device_controls_unit_pinned (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    unit_id uuid NOT NULL,
    pinned boolean NOT NULL
);


ALTER TABLE public.device_controls_unit_pinned OWNER TO postgres;

--
-- Name: device_credentials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.device_credentials (
    cred_id character varying(255) NOT NULL,
    device_id uuid NOT NULL,
    cred_val character varying(400) NOT NULL,
    cred_type character varying(255) NOT NULL,
    extra_credentials character varying(255),
    created_on timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.device_credentials OWNER TO postgres;

--
-- Name: device_sensors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.device_sensors (
    device_id uuid NOT NULL,
    sensor_id uuid NOT NULL,
    telemetry_key_id bigint NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL
);


ALTER TABLE public.device_sensors OWNER TO postgres;

--
-- Name: device_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.device_users (
    device_id uuid NOT NULL,
    user_id uuid NOT NULL,
    shared_on timestamp without time zone NOT NULL,
    access_type character varying(255) NOT NULL
);


ALTER TABLE public.device_users OWNER TO postgres;

--
-- Name: devices_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.devices_categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.devices_categories OWNER TO postgres;

--
-- Name: devices_styles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.devices_styles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    category_id uuid NOT NULL,
    filename character varying(25) NOT NULL,
    ext character varying(10) NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL
);


ALTER TABLE public.devices_styles OWNER TO postgres;

--
-- Name: devices_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.devices_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    category_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL,
    config_preset json,
    style_id uuid
);


ALTER TABLE public.devices_types OWNER TO postgres;

--
-- Name: devices_types_and_styles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.devices_types_and_styles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    type_id uuid NOT NULL,
    style_id uuid NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL
);


ALTER TABLE public.devices_types_and_styles OWNER TO postgres;

--
-- Name: devices_units; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.devices_units (
    device_id uuid NOT NULL,
    unit_id uuid NOT NULL,
    created_on timestamp without time zone
);


ALTER TABLE public.devices_units OWNER TO postgres;

--
-- Name: energy_meters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.energy_meters (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    facility_id uuid NOT NULL,
    grid_billing_account_id uuid NOT NULL,
    device_id uuid NOT NULL,
    phase integer NOT NULL,
    parent_id uuid,
    maximum_kwh integer NOT NULL,
    type_id uuid NOT NULL,
    unit_id uuid NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_by uuid NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT energy_meters_maximum_kwh_check CHECK ((maximum_kwh > 0)),
    CONSTRAINT energy_meters_phase_check CHECK ((phase > 0))
);


ALTER TABLE public.energy_meters OWNER TO postgres;

--
-- Name: energy_meters_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.energy_meters_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.energy_meters_types OWNER TO postgres;

--
-- Name: facilities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.facilities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255),
    facility_type_id uuid NOT NULL,
    created_by uuid NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    unit_id uuid,
    latitude numeric(10,8),
    longitude numeric(11,8),
    x_coordinate numeric(16,8),
    y_coordinate numeric(16,8),
    address_id uuid NOT NULL,
    occupancy_id uuid,
    first_emergency_contact uuid,
    second_emergency_contact uuid,
    maintenance_id uuid,
    security_id uuid,
    safety_id uuid
);


ALTER TABLE public.facilities OWNER TO postgres;

--
-- Name: facilities_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.facilities_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    created_by uuid,
    created_on timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.facilities_types OWNER TO postgres;

--
-- Name: facility_maintenance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.facility_maintenance (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    facility_id uuid NOT NULL,
    is_their_private_maintenance_company boolean DEFAULT false NOT NULL,
    private_maintenance_company_contact uuid,
    is_their_resident_maintenance_team boolean DEFAULT false NOT NULL,
    resident_maintenance_team_contact_id uuid,
    created_by uuid NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.facility_maintenance OWNER TO postgres;

--
-- Name: facility_maintenance_maintenance_team_trainings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.facility_maintenance_maintenance_team_trainings (
    id integer NOT NULL,
    facility_maintenance_id uuid NOT NULL,
    maintenance_team_training_id uuid NOT NULL,
    created_by uuid NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.facility_maintenance_maintenance_team_trainings OWNER TO postgres;

--
-- Name: facility_maintenance_maintenance_team_trainings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.facility_maintenance_maintenance_team_trainings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.facility_maintenance_maintenance_team_trainings_id_seq OWNER TO postgres;

--
-- Name: facility_maintenance_maintenance_team_trainings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.facility_maintenance_maintenance_team_trainings_id_seq OWNED BY public.facility_maintenance_maintenance_team_trainings.id;


--
-- Name: facility_occupancy; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.facility_occupancy (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    facility_id uuid NOT NULL,
    total_area numeric(16,8) NOT NULL,
    total_built_up_area numeric(16,8) NOT NULL,
    building_total_numbers integer NOT NULL,
    personal_access_permit uuid,
    total_facility_employees integer NOT NULL,
    total_facility_capacity integer NOT NULL,
    maximum_visitors_capacity integer NOT NULL,
    notify_if_total_personnel_number_exceed boolean DEFAULT true NOT NULL,
    maximum_vehicles_capacity integer NOT NULL,
    vehicles_access_permit uuid,
    total_facility_parking integer NOT NULL,
    notify_if_total_vehicles_parking_exceed boolean DEFAULT true NOT NULL,
    created_by uuid NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT facility_occupancy_building_total_numbers_check CHECK ((building_total_numbers > 0)),
    CONSTRAINT facility_occupancy_total_built_up_area_check CHECK ((total_built_up_area > (0)::numeric))
);


ALTER TABLE public.facility_occupancy OWNER TO postgres;

--
-- Name: facility_occupancy_vehicles_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.facility_occupancy_vehicles_types (
    facility_occupancy_id uuid NOT NULL,
    vehicles_types_id uuid NOT NULL,
    created_by uuid NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.facility_occupancy_vehicles_types OWNER TO postgres;

--
-- Name: facility_safety; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.facility_safety (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    facility_id uuid NOT NULL,
    is_their_fire_alarm_system boolean DEFAULT false NOT NULL,
    fire_alarm_system_type_id uuid NOT NULL,
    hazardous_materials_officer_contact_id uuid,
    is_facility_follow_precautionary_measures boolean DEFAULT false NOT NULL,
    is_facility_has_resident_safety_inspector boolean DEFAULT false NOT NULL,
    resident_safety_inspector_contact_id uuid,
    created_by uuid NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.facility_safety OWNER TO postgres;

--
-- Name: facility_security; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.facility_security (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    facility_id uuid NOT NULL,
    is_their_private_security_company boolean DEFAULT false NOT NULL,
    private_security_company_contact_id uuid,
    is_their_surveillance_system boolean DEFAULT false NOT NULL,
    created_by uuid NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.facility_security OWNER TO postgres;

--
-- Name: fire_alarm_systems_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fire_alarm_systems_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.fire_alarm_systems_types OWNER TO postgres;

--
-- Name: grid_billing_accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grid_billing_accounts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    label character varying(255) NOT NULL,
    number bigint NOT NULL,
    meter_serial_number character varying(255) NOT NULL,
    type_id uuid NOT NULL,
    service_class_id uuid NOT NULL,
    breaker_capacity integer NOT NULL,
    start_period timestamp with time zone NOT NULL,
    end_period timestamp with time zone NOT NULL,
    days integer NOT NULL,
    created_by uuid NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    facility_id uuid,
    CONSTRAINT grid_billing_accounts_breaker_capacity_check CHECK ((breaker_capacity > 0)),
    CONSTRAINT grid_billing_accounts_days_check CHECK ((days > 0))
);


ALTER TABLE public.grid_billing_accounts OWNER TO postgres;

--
-- Name: grid_billing_accounts_service_classes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grid_billing_accounts_service_classes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    minimal_breaker_capacity integer NOT NULL,
    maximum_breaker_capacity integer,
    fee integer NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    facility_id uuid NOT NULL,
    created_by uuid,
    CONSTRAINT grid_billing_accounts_service_cl_maximum_breaker_capacity_check CHECK ((maximum_breaker_capacity > 0)),
    CONSTRAINT grid_billing_accounts_service_cl_minimal_breaker_capacity_check CHECK ((minimal_breaker_capacity > 0)),
    CONSTRAINT grid_billing_accounts_service_classes_fee_check CHECK ((fee > 0))
);


ALTER TABLE public.grid_billing_accounts_service_classes OWNER TO postgres;

--
-- Name: grid_billing_accounts_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grid_billing_accounts_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.grid_billing_accounts_types OWNER TO postgres;

--
-- Name: icons; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.icons (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    css_class character varying(255) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.icons OWNER TO postgres;

--
-- Name: id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.id_seq OWNER TO postgres;

--
-- Name: main_energy_meters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.main_energy_meters (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    account_id uuid NOT NULL,
    meter_label character varying(255) NOT NULL,
    meter_id bigint NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_by uuid NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT main_energy_meters_meter_id_check CHECK ((meter_id > 0))
);


ALTER TABLE public.main_energy_meters OWNER TO postgres;

--
-- Name: maintenance_team_trainings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.maintenance_team_trainings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    facility_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    description text NOT NULL,
    created_by uuid NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.maintenance_team_trainings OWNER TO postgres;

--
-- Name: menus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.menus (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title character varying(255) NOT NULL,
    html_class character varying(255),
    color character varying(255),
    has_children boolean NOT NULL,
    level integer NOT NULL,
    parent_id uuid,
    priority integer NOT NULL,
    route_to character varying(255),
    created_on timestamp without time zone
);


ALTER TABLE public.menus OWNER TO postgres;

--
-- Name: menus_and_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.menus_and_roles (
    menu_id uuid NOT NULL,
    role_id uuid NOT NULL
);


ALTER TABLE public.menus_and_roles OWNER TO postgres;

--
-- Name: migratehistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migratehistory (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    migrated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.migratehistory OWNER TO postgres;

--
-- Name: migratehistory_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.migratehistory_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.migratehistory_id_seq OWNER TO postgres;

--
-- Name: migratehistory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.migratehistory_id_seq OWNED BY public.migratehistory.id;


--
-- Name: multi_factor_authentication_factors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.multi_factor_authentication_factors (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    token character varying(255) NOT NULL,
    additional_config json,
    type_id uuid NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL
);


ALTER TABLE public.multi_factor_authentication_factors OWNER TO postgres;

--
-- Name: multi_factor_authentication_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.multi_factor_authentication_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    active boolean,
    created_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.multi_factor_authentication_types OWNER TO postgres;

--
-- Name: permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.permissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    is_core boolean NOT NULL,
    created_by uuid NOT NULL,
    created_on timestamp without time zone
);


ALTER TABLE public.permissions OWNER TO postgres;

--
-- Name: permities_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.permities_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    facility_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    description text NOT NULL,
    created_by uuid NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.permities_types OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    description text NOT NULL,
    created_on timestamp without time zone,
    created_by uuid,
    facility_id uuid,
    active boolean DEFAULT true NOT NULL,
    global_role boolean DEFAULT false NOT NULL
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: roles_and_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles_and_permissions (
    name character varying(255),
    access_pattren integer NOT NULL,
    permission_id uuid NOT NULL,
    role_id uuid NOT NULL,
    created_by uuid NOT NULL,
    created_on timestamp without time zone
);


ALTER TABLE public.roles_and_permissions OWNER TO postgres;

--
-- Name: scheduled_controls; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.scheduled_controls (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    active boolean NOT NULL,
    device_id uuid NOT NULL,
    unit_id uuid NOT NULL,
    facility_id uuid NOT NULL,
    is_custom boolean NOT NULL,
    start_time bigint NOT NULL,
    end_time bigint,
    control_id uuid,
    cmd_start json NOT NULL,
    cmd_end json NOT NULL,
    repeat boolean NOT NULL,
    repeat_type character varying(50) NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    processed boolean,
    processed_on bigint,
    start_processed boolean,
    next_trigger bigint,
    has_ending boolean
);


ALTER TABLE public.scheduled_controls OWNER TO postgres;

--
-- Name: sub_energy_meters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sub_energy_meters (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    main_meter_id uuid NOT NULL,
    meter_label character varying(255) NOT NULL,
    meter_id bigint NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_by uuid NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT sub_energy_meters_meter_id_check CHECK ((meter_id > 0))
);


ALTER TABLE public.sub_energy_meters OWNER TO postgres;

--
-- Name: tariff_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tariff_categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    maximum_amp integer NOT NULL,
    minimum_amp integer NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL,
    facility_id uuid,
    fee numeric(10,2),
    CONSTRAINT tariff_categories_maximum_kwh_check CHECK ((maximum_amp > 0)),
    CONSTRAINT tariff_categories_minimum_kwh_check CHECK ((minimum_amp > 0))
);


ALTER TABLE public.tariff_categories OWNER TO postgres;

--
-- Name: tariff_categories_service_classes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tariff_categories_service_classes (
    tariff_category_id uuid NOT NULL,
    service_class_id uuid NOT NULL,
    tariff integer NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL,
    CONSTRAINT tariff_categories_service_classes_tariff_check CHECK ((tariff > 0))
);


ALTER TABLE public.tariff_categories_service_classes OWNER TO postgres;

--
-- Name: telemetries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.telemetries (
    device_id uuid NOT NULL,
    key_id bigint NOT NULL,
    "timestamp" bigint NOT NULL,
    bool boolean,
    dbl double precision,
    json json,
    long bigint,
    str character varying(255)
);


ALTER TABLE public.telemetries OWNER TO postgres;

--
-- Name: telemetries_dictionaries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.telemetries_dictionaries (
    id bigint DEFAULT nextval('public.id_seq'::regclass) NOT NULL,
    key character varying(400) NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.telemetries_dictionaries OWNER TO postgres;

--
-- Name: telemetries_latest; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.telemetries_latest (
    device_id uuid NOT NULL,
    key_id bigint NOT NULL,
    "timestamp" bigint NOT NULL,
    bool boolean,
    dbl double precision,
    json json,
    long bigint,
    str character varying(255)
);


ALTER TABLE public.telemetries_latest OWNER TO postgres;

--
-- Name: telemetries_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.telemetries_log (
    device_id uuid NOT NULL,
    key_id bigint NOT NULL,
    "timestamp" bigint NOT NULL,
    bool boolean,
    dbl double precision,
    json json,
    long bigint,
    str character varying(255)
);


ALTER TABLE public.telemetries_log OWNER TO postgres;

--
-- Name: telemetries_notif; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.telemetries_notif (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    device_id uuid NOT NULL,
    key_id bigint NOT NULL,
    "timestamp" bigint NOT NULL,
    bool boolean,
    dbl double precision,
    json json,
    long bigint,
    str character varying(255),
    msg character varying(512)
);


ALTER TABLE public.telemetries_notif OWNER TO postgres;

--
-- Name: telemetries_notif_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.telemetries_notif_users (
    notif_id uuid NOT NULL,
    user_id uuid NOT NULL,
    read boolean NOT NULL,
    read_ts bigint NOT NULL
);


ALTER TABLE public.telemetries_notif_users OWNER TO postgres;

--
-- Name: units; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.units (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    is_building boolean NOT NULL,
    level integer NOT NULL,
    parent_id uuid,
    latitude numeric(10,8),
    longitude numeric(11,8),
    x_coordinate numeric(16,8),
    y_coordinate numeric(16,8),
    type_id uuid NOT NULL,
    active boolean NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL,
    facility_id uuid NOT NULL,
    has_children boolean DEFAULT false NOT NULL,
    icon_id uuid,
    html_hex_color character varying(7),
    description text
);


ALTER TABLE public.units OWNER TO postgres;

--
-- Name: units_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.units_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    description text,
    facility_id uuid,
    global_type boolean DEFAULT false NOT NULL,
    default_level integer,
    default_type_for_its_level boolean DEFAULT false NOT NULL,
    icon_id uuid,
    CONSTRAINT units_types_default_level_check CHECK ((default_level >= 0))
);


ALTER TABLE public.units_types OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255) NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    role_id uuid NOT NULL,
    active boolean,
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    facility_id uuid,
    mfa_factor_id uuid
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_and_buildings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_and_buildings (
    user_id uuid NOT NULL,
    building_id uuid NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL
);


ALTER TABLE public.users_and_buildings OWNER TO postgres;

--
-- Name: vehicles_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vehicles_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL
);


ALTER TABLE public.vehicles_types OWNER TO postgres;

--
-- Name: water_bill; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.water_bill (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    water_grid_invoice_number character varying(255) NOT NULL,
    water_grid_account_id uuid NOT NULL,
    grid_period_begin timestamp with time zone NOT NULL,
    grid_period_end timestamp with time zone NOT NULL,
    grid_begin_reading real NOT NULL,
    grid_end_reading real NOT NULL,
    grid_consumption real NOT NULL,
    grid_cost real NOT NULL,
    system_begin_reading real NOT NULL,
    system_end_reading real NOT NULL,
    system_consumption real NOT NULL,
    system_cost real NOT NULL,
    tariff_cost real NOT NULL,
    class_cost real NOT NULL,
    global_cost json NOT NULL,
    consumption_different real NOT NULL,
    created_on timestamp without time zone DEFAULT now(),
    created_by uuid NOT NULL,
    CONSTRAINT water_bill_grid_begin_reading_check CHECK ((grid_begin_reading >= (0)::double precision)),
    CONSTRAINT water_bill_grid_consumption_check CHECK ((grid_consumption > (0)::double precision)),
    CONSTRAINT water_bill_grid_cost_check CHECK ((grid_cost > (0)::double precision)),
    CONSTRAINT water_bill_grid_end_reading_check CHECK ((grid_end_reading > (0)::double precision)),
    CONSTRAINT water_bill_system_begin_reading_check CHECK ((system_begin_reading >= (0)::double precision)),
    CONSTRAINT water_bill_system_consumption_check CHECK ((system_consumption > (0)::double precision)),
    CONSTRAINT water_bill_system_cost_check CHECK ((system_cost > (0)::double precision)),
    CONSTRAINT water_bill_system_cost_check1 CHECK ((system_cost > (0)::double precision)),
    CONSTRAINT water_bill_system_cost_check2 CHECK ((system_cost > (0)::double precision)),
    CONSTRAINT water_bill_system_end_reading_check CHECK ((system_end_reading > (0)::double precision))
);


ALTER TABLE public.water_bill OWNER TO postgres;

--
-- Name: water_bill_water_meter_consume; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.water_bill_water_meter_consume (
    water_bill_id uuid NOT NULL,
    water_meter_id uuid NOT NULL,
    water_meter_consume real NOT NULL,
    created_on timestamp without time zone DEFAULT now(),
    created_by uuid NOT NULL
);


ALTER TABLE public.water_bill_water_meter_consume OWNER TO postgres;

--
-- Name: water_grid_account; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.water_grid_account (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    number bigint NOT NULL,
    meter_serial_number character varying(255) NOT NULL,
    water_grid_provider_id uuid NOT NULL,
    service_type_id uuid NOT NULL,
    service_class_id uuid NOT NULL,
    start_period timestamp with time zone NOT NULL,
    end_period timestamp with time zone NOT NULL,
    days integer NOT NULL,
    created_by uuid NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT water_grid_account_days_check CHECK ((days > 0))
);


ALTER TABLE public.water_grid_account OWNER TO postgres;

--
-- Name: water_grid_account_global_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.water_grid_account_global_types (
    water_grid_account_id uuid NOT NULL,
    global_type_id uuid NOT NULL,
    created_on timestamp without time zone DEFAULT now(),
    created_by uuid NOT NULL
);


ALTER TABLE public.water_grid_account_global_types OWNER TO postgres;

--
-- Name: water_grid_account_service_class; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.water_grid_account_service_class (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    minimal_meter_diameter integer NOT NULL,
    maximum_meter_diameter integer,
    fee numeric(10,5) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL,
    CONSTRAINT water_grid_account_service_class_fee_check CHECK ((fee > 0.0)),
    CONSTRAINT water_grid_account_service_class_maximum_meter_diameter_check CHECK ((maximum_meter_diameter > 0)),
    CONSTRAINT water_grid_account_service_class_minimal_meter_diameter_check CHECK ((minimal_meter_diameter > 0))
);


ALTER TABLE public.water_grid_account_service_class OWNER TO postgres;

--
-- Name: water_grid_account_service_global; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.water_grid_account_service_global (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    ratio_bill numeric(10,5) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL,
    CONSTRAINT water_grid_account_service_global_ratio_bill_check CHECK ((ratio_bill > 0.0))
);


ALTER TABLE public.water_grid_account_service_global OWNER TO postgres;

--
-- Name: water_grid_account_service_sub_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.water_grid_account_service_sub_type (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    first numeric(10,5) NOT NULL,
    second numeric(10,5) NOT NULL,
    third numeric(10,5) NOT NULL,
    fourth numeric(10,5) NOT NULL,
    above numeric(10,5) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL,
    CONSTRAINT water_grid_account_service_sub_type_above_check CHECK ((above > 0.0)),
    CONSTRAINT water_grid_account_service_sub_type_first_check CHECK ((first > 0.0)),
    CONSTRAINT water_grid_account_service_sub_type_fourth_check CHECK ((fourth > 0.0)),
    CONSTRAINT water_grid_account_service_sub_type_second_check CHECK ((second > 0.0)),
    CONSTRAINT water_grid_account_service_sub_type_third_check CHECK ((third > 0.0))
);


ALTER TABLE public.water_grid_account_service_sub_type OWNER TO postgres;

--
-- Name: water_grid_account_sub_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.water_grid_account_sub_types (
    water_grid_account_id uuid NOT NULL,
    sub_type_id uuid NOT NULL,
    created_on timestamp without time zone DEFAULT now(),
    created_by uuid NOT NULL
);


ALTER TABLE public.water_grid_account_sub_types OWNER TO postgres;

--
-- Name: water_grid_account_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.water_grid_account_type (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL
);


ALTER TABLE public.water_grid_account_type OWNER TO postgres;

--
-- Name: water_grid_account_units; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.water_grid_account_units (
    water_grid_account_id uuid NOT NULL,
    unit_id uuid NOT NULL,
    created_on timestamp without time zone DEFAULT now(),
    created_by uuid NOT NULL
);


ALTER TABLE public.water_grid_account_units OWNER TO postgres;

--
-- Name: water_grid_provider; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.water_grid_provider (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL
);


ALTER TABLE public.water_grid_provider OWNER TO postgres;

--
-- Name: water_grid_water_meters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.water_grid_water_meters (
    water_grid_account_id uuid NOT NULL,
    water_meter_id uuid NOT NULL,
    created_on timestamp without time zone DEFAULT now(),
    created_by uuid NOT NULL
);


ALTER TABLE public.water_grid_water_meters OWNER TO postgres;

--
-- Name: water_meter_units; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.water_meter_units (
    water_meter_id uuid NOT NULL,
    unit_id uuid NOT NULL,
    created_on timestamp without time zone DEFAULT now(),
    created_by uuid NOT NULL
);


ALTER TABLE public.water_meter_units OWNER TO postgres;

--
-- Name: water_tank; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.water_tank (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    capacity numeric(10,5) NOT NULL,
    width numeric(10,5) NOT NULL,
    body_height numeric(10,5) NOT NULL,
    inside_water_height numeric(10,5) NOT NULL,
    length numeric(10,5) NOT NULL,
    diameter numeric(10,5),
    thickness numeric(10,5),
    max_temperature numeric(10,5),
    min_temperature numeric(10,5),
    max_pressure numeric(10,5),
    min_pressure numeric(10,5),
    water_source_id uuid NOT NULL,
    type_id uuid NOT NULL,
    location_id uuid NOT NULL,
    style_id uuid NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_by uuid NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT water_tank_body_height_check CHECK ((body_height > 0.0)),
    CONSTRAINT water_tank_capacity_check CHECK ((capacity > 0.0)),
    CONSTRAINT water_tank_diameter_check CHECK ((diameter > 0.0)),
    CONSTRAINT water_tank_inside_water_height_check CHECK ((inside_water_height > 0.0)),
    CONSTRAINT water_tank_length_check CHECK ((length > 0.0)),
    CONSTRAINT water_tank_thickness_check CHECK ((thickness > 0.0)),
    CONSTRAINT water_tank_width_check CHECK ((width > 0.0))
);


ALTER TABLE public.water_tank OWNER TO postgres;

--
-- Name: water_tank_style; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.water_tank_style (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    filename character varying(25) NOT NULL,
    name character varying(25) NOT NULL,
    ext character varying(10) NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL
);


ALTER TABLE public.water_tank_style OWNER TO postgres;

--
-- Name: water_tank_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.water_tank_type (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    created_by uuid NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.water_tank_type OWNER TO postgres;

--
-- Name: water_tank_units; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.water_tank_units (
    water_tank_id uuid NOT NULL,
    unit_id uuid NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL
);


ALTER TABLE public.water_tank_units OWNER TO postgres;

--
-- Name: water_tank_water_sensors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.water_tank_water_sensors (
    water_tank_id uuid NOT NULL,
    water_sensor_id uuid NOT NULL,
    telemetry_key_id bigint NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL
);


ALTER TABLE public.water_tank_water_sensors OWNER TO postgres;

--
-- Name: water_tank_water_valves; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.water_tank_water_valves (
    water_tank_id uuid NOT NULL,
    water_valve_id uuid NOT NULL,
    created_on timestamp without time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL
);


ALTER TABLE public.water_tank_water_valves OWNER TO postgres;

--
-- Name: facility_maintenance_maintenance_team_trainings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_maintenance_maintenance_team_trainings ALTER COLUMN id SET DEFAULT nextval('public.facility_maintenance_maintenance_team_trainings_id_seq'::regclass);


--
-- Name: migratehistory id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migratehistory ALTER COLUMN id SET DEFAULT nextval('public.migratehistory_id_seq'::regclass);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: alarms alarms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alarms
    ADD CONSTRAINT alarms_pkey PRIMARY KEY (id);


--
-- Name: alarms_severities alarms_severities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alarms_severities
    ADD CONSTRAINT alarms_severities_pkey PRIMARY KEY (id);


--
-- Name: alarms_types alarms_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alarms_types
    ADD CONSTRAINT alarms_types_pkey PRIMARY KEY (id);


--
-- Name: consumption_categories_grid_billing_accounts_types consumption_categories_grid_billing_accounts_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consumption_categories_grid_billing_accounts_types
    ADD CONSTRAINT consumption_categories_grid_billing_accounts_types_pkey PRIMARY KEY (consumption_category_id, grid_billing_account_type_id);


--
-- Name: consumption_categories consumption_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consumption_categories
    ADD CONSTRAINT consumption_categories_pkey PRIMARY KEY (id);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: contacts_titles contacts_titles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacts_titles
    ADD CONSTRAINT contacts_titles_pkey PRIMARY KEY (id);


--
-- Name: device_control_type_icon device_control_type_icon_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_control_type_icon
    ADD CONSTRAINT device_control_type_icon_pkey PRIMARY KEY (id);


--
-- Name: device_control_types device_control_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_control_types
    ADD CONSTRAINT device_control_types_pkey PRIMARY KEY (id);


--
-- Name: device_controls device_controls_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_controls
    ADD CONSTRAINT device_controls_pkey PRIMARY KEY (id);


--
-- Name: device_controls_unit_pinned device_controls_unit_pinned_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_controls_unit_pinned
    ADD CONSTRAINT device_controls_unit_pinned_pkey PRIMARY KEY (id);


--
-- Name: device device_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device
    ADD CONSTRAINT device_pkey PRIMARY KEY (id);


--
-- Name: device_sensors device_sensors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_sensors
    ADD CONSTRAINT device_sensors_pkey PRIMARY KEY (device_id, sensor_id, telemetry_key_id);


--
-- Name: device_users device_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_users
    ADD CONSTRAINT device_users_pkey PRIMARY KEY (device_id, user_id);


--
-- Name: devices_categories devices_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_categories
    ADD CONSTRAINT devices_categories_pkey PRIMARY KEY (id);


--
-- Name: devices_styles devices_styles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_styles
    ADD CONSTRAINT devices_styles_pkey PRIMARY KEY (id);


--
-- Name: devices_types_and_styles devices_types_and_styles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_types_and_styles
    ADD CONSTRAINT devices_types_and_styles_pkey PRIMARY KEY (id);


--
-- Name: devices_types devices_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_types
    ADD CONSTRAINT devices_types_pkey PRIMARY KEY (id);


--
-- Name: devices_units devices_units_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_units
    ADD CONSTRAINT devices_units_pkey PRIMARY KEY (device_id, unit_id);


--
-- Name: energy_meters energy_meters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.energy_meters
    ADD CONSTRAINT energy_meters_pkey PRIMARY KEY (id);


--
-- Name: energy_meters_types energy_meters_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.energy_meters_types
    ADD CONSTRAINT energy_meters_types_pkey PRIMARY KEY (id);


--
-- Name: facilities facilities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facilities
    ADD CONSTRAINT facilities_pkey PRIMARY KEY (id);


--
-- Name: facilities_types facilities_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facilities_types
    ADD CONSTRAINT facilities_types_pkey PRIMARY KEY (id);


--
-- Name: facility_maintenance_maintenance_team_trainings facility_maintenance_maintenance_team_trainings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_maintenance_maintenance_team_trainings
    ADD CONSTRAINT facility_maintenance_maintenance_team_trainings_pkey PRIMARY KEY (id);


--
-- Name: facility_maintenance facility_maintenance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_maintenance
    ADD CONSTRAINT facility_maintenance_pkey PRIMARY KEY (id);


--
-- Name: facility_occupancy facility_occupancy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_occupancy
    ADD CONSTRAINT facility_occupancy_pkey PRIMARY KEY (id);


--
-- Name: facility_occupancy_vehicles_types facility_occupancy_vehicles_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_occupancy_vehicles_types
    ADD CONSTRAINT facility_occupancy_vehicles_types_pkey PRIMARY KEY (facility_occupancy_id, vehicles_types_id);


--
-- Name: facility_safety facility_safety_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_safety
    ADD CONSTRAINT facility_safety_pkey PRIMARY KEY (id);


--
-- Name: facility_security facility_security_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_security
    ADD CONSTRAINT facility_security_pkey PRIMARY KEY (id);


--
-- Name: fire_alarm_systems_types fire_alarm_systems_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fire_alarm_systems_types
    ADD CONSTRAINT fire_alarm_systems_types_pkey PRIMARY KEY (id);


--
-- Name: grid_billing_accounts grid_billing_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grid_billing_accounts
    ADD CONSTRAINT grid_billing_accounts_pkey PRIMARY KEY (id);


--
-- Name: grid_billing_accounts_service_classes grid_billing_accounts_service_classes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grid_billing_accounts_service_classes
    ADD CONSTRAINT grid_billing_accounts_service_classes_pkey PRIMARY KEY (id);


--
-- Name: grid_billing_accounts_types grid_billing_accounts_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grid_billing_accounts_types
    ADD CONSTRAINT grid_billing_accounts_types_pkey PRIMARY KEY (id);


--
-- Name: icons icons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.icons
    ADD CONSTRAINT icons_pkey PRIMARY KEY (id);


--
-- Name: main_energy_meters main_energy_meters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.main_energy_meters
    ADD CONSTRAINT main_energy_meters_pkey PRIMARY KEY (id);


--
-- Name: maintenance_team_trainings maintenance_team_trainings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_team_trainings
    ADD CONSTRAINT maintenance_team_trainings_pkey PRIMARY KEY (id);


--
-- Name: menus_and_roles menus_and_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menus_and_roles
    ADD CONSTRAINT menus_and_roles_pkey PRIMARY KEY (menu_id, role_id);


--
-- Name: menus menus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menus
    ADD CONSTRAINT menus_pkey PRIMARY KEY (id);


--
-- Name: migratehistory migratehistory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migratehistory
    ADD CONSTRAINT migratehistory_pkey PRIMARY KEY (id);


--
-- Name: multi_factor_authentication_factors multi_factor_authentication_factors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.multi_factor_authentication_factors
    ADD CONSTRAINT multi_factor_authentication_factors_pkey PRIMARY KEY (id);


--
-- Name: multi_factor_authentication_types multi_factor_authentication_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.multi_factor_authentication_types
    ADD CONSTRAINT multi_factor_authentication_types_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: permities_types permities_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permities_types
    ADD CONSTRAINT permities_types_pkey PRIMARY KEY (id);


--
-- Name: roles_and_permissions roles_and_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles_and_permissions
    ADD CONSTRAINT roles_and_permissions_pkey PRIMARY KEY (permission_id, role_id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: scheduled_controls scheduled_controls_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scheduled_controls
    ADD CONSTRAINT scheduled_controls_pkey PRIMARY KEY (id);


--
-- Name: sub_energy_meters sub_energy_meters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sub_energy_meters
    ADD CONSTRAINT sub_energy_meters_pkey PRIMARY KEY (id);


--
-- Name: tariff_categories tariff_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tariff_categories
    ADD CONSTRAINT tariff_categories_pkey PRIMARY KEY (id);


--
-- Name: tariff_categories_service_classes tariff_categories_service_classes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tariff_categories_service_classes
    ADD CONSTRAINT tariff_categories_service_classes_pkey PRIMARY KEY (tariff_category_id, service_class_id);


--
-- Name: telemetries_dictionaries telemetries_dictionaries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telemetries_dictionaries
    ADD CONSTRAINT telemetries_dictionaries_pkey PRIMARY KEY (id);


--
-- Name: telemetries_latest telemetries_latest_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telemetries_latest
    ADD CONSTRAINT telemetries_latest_pkey PRIMARY KEY (device_id, key_id);


--
-- Name: telemetries_log telemetries_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telemetries_log
    ADD CONSTRAINT telemetries_log_pkey PRIMARY KEY (device_id, key_id, "timestamp");


--
-- Name: telemetries_notif telemetries_notif_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telemetries_notif
    ADD CONSTRAINT telemetries_notif_pkey PRIMARY KEY (id);


--
-- Name: telemetries_notif_users telemetries_notif_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telemetries_notif_users
    ADD CONSTRAINT telemetries_notif_users_pkey PRIMARY KEY (notif_id, user_id);


--
-- Name: telemetries telemetries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telemetries
    ADD CONSTRAINT telemetries_pkey PRIMARY KEY (device_id, key_id, "timestamp");


--
-- Name: units units_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_pkey PRIMARY KEY (id);


--
-- Name: units_types units_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.units_types
    ADD CONSTRAINT units_types_pkey PRIMARY KEY (id);


--
-- Name: users_and_buildings users_and_buildings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_and_buildings
    ADD CONSTRAINT users_and_buildings_pkey PRIMARY KEY (user_id, building_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vehicles_types vehicles_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicles_types
    ADD CONSTRAINT vehicles_types_pkey PRIMARY KEY (id);


--
-- Name: water_bill water_bill_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_bill
    ADD CONSTRAINT water_bill_pkey PRIMARY KEY (id);


--
-- Name: water_bill_water_meter_consume water_bill_water_meter_consume_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_bill_water_meter_consume
    ADD CONSTRAINT water_bill_water_meter_consume_pkey PRIMARY KEY (water_bill_id, water_meter_id);


--
-- Name: water_grid_account_global_types water_grid_account_global_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_account_global_types
    ADD CONSTRAINT water_grid_account_global_types_pkey PRIMARY KEY (water_grid_account_id, global_type_id);


--
-- Name: water_grid_account water_grid_account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_account
    ADD CONSTRAINT water_grid_account_pkey PRIMARY KEY (id);


--
-- Name: water_grid_account_service_class water_grid_account_service_class_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_account_service_class
    ADD CONSTRAINT water_grid_account_service_class_pkey PRIMARY KEY (id);


--
-- Name: water_grid_account_service_global water_grid_account_service_global_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_account_service_global
    ADD CONSTRAINT water_grid_account_service_global_pkey PRIMARY KEY (id);


--
-- Name: water_grid_account_service_sub_type water_grid_account_service_sub_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_account_service_sub_type
    ADD CONSTRAINT water_grid_account_service_sub_type_pkey PRIMARY KEY (id);


--
-- Name: water_grid_account_sub_types water_grid_account_sub_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_account_sub_types
    ADD CONSTRAINT water_grid_account_sub_types_pkey PRIMARY KEY (water_grid_account_id, sub_type_id);


--
-- Name: water_grid_account_type water_grid_account_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_account_type
    ADD CONSTRAINT water_grid_account_type_pkey PRIMARY KEY (id);


--
-- Name: water_grid_account_units water_grid_account_units_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_account_units
    ADD CONSTRAINT water_grid_account_units_pkey PRIMARY KEY (water_grid_account_id, unit_id);


--
-- Name: water_grid_provider water_grid_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_provider
    ADD CONSTRAINT water_grid_provider_pkey PRIMARY KEY (id);


--
-- Name: water_grid_water_meters water_grid_water_meters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_water_meters
    ADD CONSTRAINT water_grid_water_meters_pkey PRIMARY KEY (water_grid_account_id, water_meter_id);


--
-- Name: water_meter_units water_meter_units_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_meter_units
    ADD CONSTRAINT water_meter_units_pkey PRIMARY KEY (unit_id, water_meter_id);


--
-- Name: water_tank water_tank_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_tank
    ADD CONSTRAINT water_tank_pkey PRIMARY KEY (id);


--
-- Name: water_tank_style water_tank_style_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_tank_style
    ADD CONSTRAINT water_tank_style_pkey PRIMARY KEY (id);


--
-- Name: water_tank_type water_tank_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_tank_type
    ADD CONSTRAINT water_tank_type_pkey PRIMARY KEY (id);


--
-- Name: water_tank_units water_tank_units_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_tank_units
    ADD CONSTRAINT water_tank_units_pkey PRIMARY KEY (water_tank_id, unit_id);


--
-- Name: water_tank_water_sensors water_tank_water_sensors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_tank_water_sensors
    ADD CONSTRAINT water_tank_water_sensors_pkey PRIMARY KEY (water_tank_id, water_sensor_id, telemetry_key_id);


--
-- Name: water_tank_water_valves water_tank_water_valves_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_tank_water_valves
    ADD CONSTRAINT water_tank_water_valves_pkey PRIMARY KEY (water_tank_id, water_valve_id);


--
-- Name: address_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX address_created_by ON public.addresses USING btree (created_by);


--
-- Name: alarm_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX alarm_created_by ON public.alarms USING btree (created_by);


--
-- Name: alarm_severity_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX alarm_severity_id ON public.alarms USING btree (severity_id);


--
-- Name: alarm_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX alarm_type_id ON public.alarms USING btree (type_id);


--
-- Name: alarm_variable_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX alarm_variable_id ON public.alarms USING btree (variable_id);


--
-- Name: alarmseverity_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX alarmseverity_created_by ON public.alarms_severities USING btree (created_by);


--
-- Name: alarmseverity_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX alarmseverity_name ON public.alarms_severities USING btree (name);


--
-- Name: alarmtype_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX alarmtype_name ON public.alarms_types USING btree (name);


--
-- Name: consumptioncategoriesgridbillingaccounttype_consumption__351250; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX consumptioncategoriesgridbillingaccounttype_consumption__351250 ON public.consumption_categories_grid_billing_accounts_types USING btree (consumption_category_id, grid_billing_account_type_id);


--
-- Name: consumptioncategoriesgridbillingaccounttype_consumption__e16f0e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX consumptioncategoriesgridbillingaccounttype_consumption__e16f0e ON public.consumption_categories_grid_billing_accounts_types USING btree (consumption_category_id);


--
-- Name: consumptioncategoriesgridbillingaccounttype_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX consumptioncategoriesgridbillingaccounttype_created_by ON public.consumption_categories_grid_billing_accounts_types USING btree (created_by);


--
-- Name: consumptioncategoriesgridbillingaccounttype_grid_billing_adda13; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX consumptioncategoriesgridbillingaccounttype_grid_billing_adda13 ON public.consumption_categories_grid_billing_accounts_types USING btree (grid_billing_account_type_id);


--
-- Name: consumptioncategory_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX consumptioncategory_created_by ON public.consumption_categories USING btree (created_by);


--
-- Name: consumptioncategory_facility_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX consumptioncategory_facility_id ON public.consumption_categories USING btree (facility_id);


--
-- Name: contact_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX contact_created_by ON public.contacts USING btree (created_by);


--
-- Name: contact_facility_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX contact_facility_id ON public.contacts USING btree (facility_id);


--
-- Name: contact_title_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX contact_title_id ON public.contacts USING btree (title_id);


--
-- Name: contacts_facility_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX contacts_facility_id ON public.contacts USING btree (facility_id);


--
-- Name: contacts_titles_facility_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX contacts_titles_facility_id ON public.contacts_titles USING btree (facility_id);


--
-- Name: contacttitle_facility_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX contacttitle_facility_id ON public.contacts_titles USING btree (facility_id);


--
-- Name: contacttitle_name_facility_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX contacttitle_name_facility_id ON public.contacts_titles USING btree (name, facility_id);


--
-- Name: device_controls_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX device_controls_created_by ON public.device_controls USING btree (created_by);


--
-- Name: device_controls_device_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX device_controls_device_id ON public.device_controls USING btree (device_id);


--
-- Name: device_controls_name_unit_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX device_controls_name_unit_id ON public.device_controls USING btree (name, unit_id);


--
-- Name: device_controls_unit_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX device_controls_unit_id ON public.device_controls USING btree (unit_id);


--
-- Name: device_controls_unit_pinned_unit_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX device_controls_unit_pinned_unit_id ON public.device_controls_unit_pinned USING btree (unit_id);


--
-- Name: device_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX device_created_by ON public.device USING btree (created_by);


--
-- Name: device_facility_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX device_facility_id ON public.device USING btree (facility_id);


--
-- Name: device_gateway_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX device_gateway_id ON public.device USING btree (gateway_id);


--
-- Name: device_label; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX device_label ON public.device USING btree (label);


--
-- Name: device_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX device_name ON public.device USING btree (name);


--
-- Name: device_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX device_type_id ON public.device USING btree (type_id);


--
-- Name: device_unit_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX device_unit_id ON public.device USING btree (unit_id);


--
-- Name: devicecategories_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX devicecategories_name ON public.devices_categories USING btree (name);


--
-- Name: devicecontrolicon_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX devicecontrolicon_created_by ON public.device_control_type_icon USING btree (created_by);


--
-- Name: devicecontrolicon_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX devicecontrolicon_name ON public.device_control_type_icon USING btree (name);


--
-- Name: devicecontroltypes_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX devicecontroltypes_name ON public.device_control_types USING btree (name);


--
-- Name: devicecredentials_device_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX devicecredentials_device_id ON public.device_credentials USING btree (device_id);


--
-- Name: devicecredentials_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX devicecredentials_id ON public.device_credentials USING btree (cred_id);


--
-- Name: devicestyles_category_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX devicestyles_category_id ON public.devices_styles USING btree (category_id);


--
-- Name: devicestyles_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX devicestyles_created_by ON public.devices_styles USING btree (created_by);


--
-- Name: devicetypes_category_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX devicetypes_category_id ON public.devices_types USING btree (category_id);


--
-- Name: devicetypes_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX devicetypes_created_by ON public.devices_types USING btree (created_by);


--
-- Name: devicetypes_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX devicetypes_name ON public.devices_types USING btree (name);


--
-- Name: devicetypesandstyles_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX devicetypesandstyles_created_by ON public.devices_types_and_styles USING btree (created_by);


--
-- Name: devicetypesandstyles_style_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX devicetypesandstyles_style_id ON public.devices_types_and_styles USING btree (style_id);


--
-- Name: devicetypesandstyles_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX devicetypesandstyles_type_id ON public.devices_types_and_styles USING btree (type_id);


--
-- Name: deviceunits_device_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX deviceunits_device_id ON public.devices_units USING btree (device_id);


--
-- Name: deviceunits_device_id_unit_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX deviceunits_device_id_unit_id ON public.devices_units USING btree (device_id, unit_id);


--
-- Name: deviceunits_unit_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX deviceunits_unit_id ON public.devices_units USING btree (unit_id);


--
-- Name: deviceusers_device_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX deviceusers_device_id ON public.device_users USING btree (device_id);


--
-- Name: deviceusers_device_id_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX deviceusers_device_id_user_id ON public.device_users USING btree (device_id, user_id);


--
-- Name: deviceusers_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX deviceusers_user_id ON public.device_users USING btree (user_id);


--
-- Name: energymeter_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX energymeter_created_by ON public.energy_meters USING btree (created_by);


--
-- Name: energymeter_device_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX energymeter_device_id ON public.energy_meters USING btree (device_id);


--
-- Name: energymeter_facility_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX energymeter_facility_id ON public.energy_meters USING btree (facility_id);


--
-- Name: energymeter_grid_billing_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX energymeter_grid_billing_account_id ON public.energy_meters USING btree (grid_billing_account_id);


--
-- Name: energymeter_parent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX energymeter_parent_id ON public.energy_meters USING btree (parent_id);


--
-- Name: energymeter_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX energymeter_type_id ON public.energy_meters USING btree (type_id);


--
-- Name: energymeter_unit_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX energymeter_unit_id ON public.energy_meters USING btree (unit_id);


--
-- Name: energymetertype_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX energymetertype_name ON public.energy_meters_types USING btree (name);


--
-- Name: facilities_address_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilities_address_id ON public.facilities USING btree (address_id);


--
-- Name: facilities_first_emergency_contact; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilities_first_emergency_contact ON public.facilities USING btree (first_emergency_contact);


--
-- Name: facilities_maintenance_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilities_maintenance_id ON public.facilities USING btree (maintenance_id);


--
-- Name: facilities_occupancy_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilities_occupancy_id ON public.facilities USING btree (occupancy_id);


--
-- Name: facilities_safety_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilities_safety_id ON public.facilities USING btree (safety_id);


--
-- Name: facilities_second_emergency_contact; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilities_second_emergency_contact ON public.facilities USING btree (second_emergency_contact);


--
-- Name: facilities_security_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilities_security_id ON public.facilities USING btree (security_id);


--
-- Name: facility_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facility_created_by ON public.facilities USING btree (created_by);


--
-- Name: facility_facility_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facility_facility_type_id ON public.facilities USING btree (facility_type_id);


--
-- Name: facility_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX facility_name ON public.facilities USING btree (name);


--
-- Name: facility_unit_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facility_unit_id ON public.facilities USING btree (unit_id);


--
-- Name: facilitymaintenance_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilitymaintenance_created_by ON public.facility_maintenance USING btree (created_by);


--
-- Name: facilitymaintenance_facility_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX facilitymaintenance_facility_id ON public.facility_maintenance USING btree (facility_id);


--
-- Name: facilitymaintenance_private_maintenance_company_contact; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilitymaintenance_private_maintenance_company_contact ON public.facility_maintenance USING btree (private_maintenance_company_contact);


--
-- Name: facilitymaintenance_resident_maintenance_team_contact_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilitymaintenance_resident_maintenance_team_contact_id ON public.facility_maintenance USING btree (resident_maintenance_team_contact_id);


--
-- Name: facilitymaintenancemaintenanceteamtraining_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilitymaintenancemaintenanceteamtraining_created_by ON public.facility_maintenance_maintenance_team_trainings USING btree (created_by);


--
-- Name: facilitymaintenancemaintenanceteamtraining_facility_main_73b9a7; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilitymaintenancemaintenanceteamtraining_facility_main_73b9a7 ON public.facility_maintenance_maintenance_team_trainings USING btree (facility_maintenance_id);


--
-- Name: facilitymaintenancemaintenanceteamtraining_maintenance_t_4ca247; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilitymaintenancemaintenanceteamtraining_maintenance_t_4ca247 ON public.facility_maintenance_maintenance_team_trainings USING btree (maintenance_team_training_id);


--
-- Name: facilityoccupancy_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilityoccupancy_created_by ON public.facility_occupancy USING btree (created_by);


--
-- Name: facilityoccupancy_facility_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX facilityoccupancy_facility_id ON public.facility_occupancy USING btree (facility_id);


--
-- Name: facilityoccupancy_personal_access_permit; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilityoccupancy_personal_access_permit ON public.facility_occupancy USING btree (personal_access_permit);


--
-- Name: facilityoccupancy_vehicles_access_permit; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilityoccupancy_vehicles_access_permit ON public.facility_occupancy USING btree (vehicles_access_permit);


--
-- Name: facilityoccupancyvehicletype_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilityoccupancyvehicletype_created_by ON public.facility_occupancy_vehicles_types USING btree (created_by);


--
-- Name: facilityoccupancyvehicletype_facility_occupancy_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilityoccupancyvehicletype_facility_occupancy_id ON public.facility_occupancy_vehicles_types USING btree (facility_occupancy_id);


--
-- Name: facilityoccupancyvehicletype_facility_occupancy_id_vehic_ac9931; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX facilityoccupancyvehicletype_facility_occupancy_id_vehic_ac9931 ON public.facility_occupancy_vehicles_types USING btree (facility_occupancy_id, vehicles_types_id);


--
-- Name: facilityoccupancyvehicletype_vehicles_types_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilityoccupancyvehicletype_vehicles_types_id ON public.facility_occupancy_vehicles_types USING btree (vehicles_types_id);


--
-- Name: facilitysafety_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilitysafety_created_by ON public.facility_safety USING btree (created_by);


--
-- Name: facilitysafety_facility_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX facilitysafety_facility_id ON public.facility_safety USING btree (facility_id);


--
-- Name: facilitysafety_fire_alarm_system_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilitysafety_fire_alarm_system_type_id ON public.facility_safety USING btree (fire_alarm_system_type_id);


--
-- Name: facilitysafety_hazardous_materials_officer_contact_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilitysafety_hazardous_materials_officer_contact_id ON public.facility_safety USING btree (hazardous_materials_officer_contact_id);


--
-- Name: facilitysafety_resident_safety_inspector_contact_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilitysafety_resident_safety_inspector_contact_id ON public.facility_safety USING btree (resident_safety_inspector_contact_id);


--
-- Name: facilitysecurity_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilitysecurity_created_by ON public.facility_security USING btree (created_by);


--
-- Name: facilitysecurity_facility_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX facilitysecurity_facility_id ON public.facility_security USING btree (facility_id);


--
-- Name: facilitysecurity_private_security_company_contact_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilitysecurity_private_security_company_contact_id ON public.facility_security USING btree (private_security_company_contact_id);


--
-- Name: facilitytypes_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX facilitytypes_created_by ON public.facilities_types USING btree (created_by);


--
-- Name: facilitytypes_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX facilitytypes_name ON public.facilities_types USING btree (name);


--
-- Name: firealarmsystemtype_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX firealarmsystemtype_name ON public.fire_alarm_systems_types USING btree (name);


--
-- Name: grid_billing_accounts_facility_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX grid_billing_accounts_facility_id ON public.grid_billing_accounts USING btree (facility_id);


--
-- Name: grid_billing_accounts_service_classes_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX grid_billing_accounts_service_classes_created_by ON public.grid_billing_accounts_service_classes USING btree (created_by);


--
-- Name: grid_billing_accounts_service_classes_facility_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX grid_billing_accounts_service_classes_facility_id ON public.grid_billing_accounts_service_classes USING btree (facility_id);


--
-- Name: gridbillingaccount_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX gridbillingaccount_created_by ON public.grid_billing_accounts USING btree (created_by);


--
-- Name: gridbillingaccount_label; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX gridbillingaccount_label ON public.grid_billing_accounts USING btree (label);


--
-- Name: gridbillingaccount_meter_serial_number; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX gridbillingaccount_meter_serial_number ON public.grid_billing_accounts USING btree (meter_serial_number);


--
-- Name: gridbillingaccount_number; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX gridbillingaccount_number ON public.grid_billing_accounts USING btree (number);


--
-- Name: gridbillingaccount_service_class_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX gridbillingaccount_service_class_id ON public.grid_billing_accounts USING btree (service_class_id);


--
-- Name: gridbillingaccount_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX gridbillingaccount_type_id ON public.grid_billing_accounts USING btree (type_id);


--
-- Name: gridbillingaccountserviceclass_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX gridbillingaccountserviceclass_name ON public.grid_billing_accounts_service_classes USING btree (name);


--
-- Name: gridbillingaccounttypes_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX gridbillingaccounttypes_name ON public.grid_billing_accounts_types USING btree (name);


--
-- Name: icon_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX icon_name ON public.icons USING btree (name);


--
-- Name: idx_role_name_facility_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_role_name_facility_id ON public.roles USING btree (name, facility_id);


--
-- Name: mainenergymeter_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX mainenergymeter_account_id ON public.main_energy_meters USING btree (account_id);


--
-- Name: mainenergymeter_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX mainenergymeter_created_by ON public.main_energy_meters USING btree (created_by);


--
-- Name: mainenergymeter_meter_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX mainenergymeter_meter_id ON public.main_energy_meters USING btree (meter_id);


--
-- Name: mainenergymeter_meter_label; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX mainenergymeter_meter_label ON public.main_energy_meters USING btree (meter_label);


--
-- Name: maintenanceteamtraining_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX maintenanceteamtraining_created_by ON public.maintenance_team_trainings USING btree (created_by);


--
-- Name: maintenanceteamtraining_facility_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX maintenanceteamtraining_facility_id ON public.maintenance_team_trainings USING btree (facility_id);


--
-- Name: menu_parent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX menu_parent_id ON public.menus USING btree (parent_id);


--
-- Name: menu_title; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX menu_title ON public.menus USING btree (title);


--
-- Name: menuandroles_menu_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX menuandroles_menu_id ON public.menus_and_roles USING btree (menu_id);


--
-- Name: menuandroles_role_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX menuandroles_role_id ON public.menus_and_roles USING btree (role_id);


--
-- Name: menuandroles_role_id_menu_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX menuandroles_role_id_menu_id ON public.menus_and_roles USING btree (role_id, menu_id);


--
-- Name: multifactorauthenticationfactor_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX multifactorauthenticationfactor_created_by ON public.multi_factor_authentication_factors USING btree (created_by);


--
-- Name: multifactorauthenticationfactor_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX multifactorauthenticationfactor_type_id ON public.multi_factor_authentication_factors USING btree (type_id);


--
-- Name: multifactorauthenticationtype_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX multifactorauthenticationtype_name ON public.multi_factor_authentication_types USING btree (name);


--
-- Name: permission_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX permission_created_by ON public.permissions USING btree (created_by);


--
-- Name: permission_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX permission_name ON public.permissions USING btree (name);


--
-- Name: permittype_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX permittype_created_by ON public.permities_types USING btree (created_by);


--
-- Name: permittype_facility_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX permittype_facility_id ON public.permities_types USING btree (facility_id);


--
-- Name: permittype_name_facility_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX permittype_name_facility_id ON public.permities_types USING btree (name, facility_id);


--
-- Name: role_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX role_created_by ON public.roles USING btree (created_by);


--
-- Name: roleandpermissions_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX roleandpermissions_created_by ON public.roles_and_permissions USING btree (created_by);


--
-- Name: roleandpermissions_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX roleandpermissions_name ON public.roles_and_permissions USING btree (name);


--
-- Name: roleandpermissions_permission_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX roleandpermissions_permission_id ON public.roles_and_permissions USING btree (permission_id);


--
-- Name: roleandpermissions_role_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX roleandpermissions_role_id ON public.roles_and_permissions USING btree (role_id);


--
-- Name: roleandpermissions_role_id_permission_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX roleandpermissions_role_id_permission_id ON public.roles_and_permissions USING btree (role_id, permission_id);


--
-- Name: roles_facility_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX roles_facility_id ON public.roles USING btree (facility_id);


--
-- Name: scheduledcontrol_control_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX scheduledcontrol_control_id ON public.scheduled_controls USING btree (control_id);


--
-- Name: scheduledcontrol_device_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX scheduledcontrol_device_id ON public.scheduled_controls USING btree (device_id);


--
-- Name: scheduledcontrol_facility_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX scheduledcontrol_facility_id ON public.scheduled_controls USING btree (facility_id);


--
-- Name: scheduledcontrol_name_facility_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX scheduledcontrol_name_facility_id ON public.scheduled_controls USING btree (name, facility_id);


--
-- Name: scheduledcontrol_unit_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX scheduledcontrol_unit_id ON public.scheduled_controls USING btree (unit_id);


--
-- Name: subenergymeter_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX subenergymeter_created_by ON public.sub_energy_meters USING btree (created_by);


--
-- Name: subenergymeter_main_meter_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX subenergymeter_main_meter_id ON public.sub_energy_meters USING btree (main_meter_id);


--
-- Name: subenergymeter_meter_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX subenergymeter_meter_id ON public.sub_energy_meters USING btree (meter_id);


--
-- Name: subenergymeter_meter_label; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX subenergymeter_meter_label ON public.sub_energy_meters USING btree (meter_label);


--
-- Name: tariff_categories_facility_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tariff_categories_facility_id ON public.tariff_categories USING btree (facility_id);


--
-- Name: tariffcategory_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tariffcategory_created_by ON public.tariff_categories USING btree (created_by);


--
-- Name: tariffcategory_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX tariffcategory_name ON public.tariff_categories USING btree (name);


--
-- Name: tariffcategoryserviceclass_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tariffcategoryserviceclass_created_by ON public.tariff_categories_service_classes USING btree (created_by);


--
-- Name: tariffcategoryserviceclass_service_class_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tariffcategoryserviceclass_service_class_id ON public.tariff_categories_service_classes USING btree (service_class_id);


--
-- Name: tariffcategoryserviceclass_tariff_category_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tariffcategoryserviceclass_tariff_category_id ON public.tariff_categories_service_classes USING btree (tariff_category_id);


--
-- Name: telemetries_log_device_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX telemetries_log_device_id ON public.telemetries_log USING btree (device_id);


--
-- Name: telemetries_log_device_id_key_id_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX telemetries_log_device_id_key_id_timestamp ON public.telemetries_log USING btree (device_id, key_id, "timestamp");


--
-- Name: telemetries_notif_device_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX telemetries_notif_device_id ON public.telemetries_notif USING btree (device_id);


--
-- Name: telemetries_notif_users_notif_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX telemetries_notif_users_notif_id ON public.telemetries_notif_users USING btree (notif_id);


--
-- Name: telemetries_notif_users_notif_id_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX telemetries_notif_users_notif_id_user_id ON public.telemetries_notif_users USING btree (notif_id, user_id);


--
-- Name: telemetries_notif_users_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX telemetries_notif_users_user_id ON public.telemetries_notif_users USING btree (user_id);


--
-- Name: telemetry_device_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX telemetry_device_id ON public.telemetries USING btree (device_id);


--
-- Name: telemetry_device_id_key_id_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX telemetry_device_id_key_id_timestamp ON public.telemetries USING btree (device_id, key_id, "timestamp");


--
-- Name: telemetrydictionarues_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX telemetrydictionarues_key ON public.telemetries_dictionaries USING btree (key);


--
-- Name: unit_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX unit_created_by ON public.units USING btree (created_by);


--
-- Name: unit_facility_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX unit_facility_id ON public.units USING btree (facility_id);


--
-- Name: unit_level; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX unit_level ON public.units USING btree (level);


--
-- Name: unit_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unit_name ON public.units USING btree (name);


--
-- Name: unit_parent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX unit_parent_id ON public.units USING btree (parent_id);


--
-- Name: unit_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX unit_type_id ON public.units USING btree (type_id);


--
-- Name: units_icon_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX units_icon_id ON public.units USING btree (icon_id);


--
-- Name: units_types_facility_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX units_types_facility_id ON public.units_types USING btree (facility_id);


--
-- Name: units_types_icon_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX units_types_icon_id ON public.units_types USING btree (icon_id);


--
-- Name: unittypes_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX unittypes_created_by ON public.units_types USING btree (created_by);


--
-- Name: unittypes_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unittypes_name ON public.units_types USING btree (name);


--
-- Name: user_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX user_email ON public.users USING btree (email);


--
-- Name: user_role_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_role_id ON public.users USING btree (role_id);


--
-- Name: userandbuildings_building_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX userandbuildings_building_id ON public.users_and_buildings USING btree (building_id);


--
-- Name: userandbuildings_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX userandbuildings_created_by ON public.users_and_buildings USING btree (created_by);


--
-- Name: userandbuildings_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX userandbuildings_user_id ON public.users_and_buildings USING btree (user_id);


--
-- Name: userandbuildings_user_id_building_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX userandbuildings_user_id_building_id ON public.users_and_buildings USING btree (user_id, building_id);


--
-- Name: users_facility_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_facility_id ON public.users USING btree (facility_id);


--
-- Name: users_mfa_factor_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_mfa_factor_id ON public.users USING btree (mfa_factor_id);


--
-- Name: vehicletype_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX vehicletype_created_by ON public.vehicles_types USING btree (created_by);


--
-- Name: vehicletype_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX vehicletype_name ON public.vehicles_types USING btree (name);


--
-- Name: waterbill_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX waterbill_created_by ON public.water_bill USING btree (created_by);


--
-- Name: waterbill_water_grid_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX waterbill_water_grid_account_id ON public.water_bill USING btree (water_grid_account_id);


--
-- Name: waterbill_water_grid_invoice_number; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX waterbill_water_grid_invoice_number ON public.water_bill USING btree (water_grid_invoice_number);


--
-- Name: waterbillwatermeterconsume_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX waterbillwatermeterconsume_created_by ON public.water_bill_water_meter_consume USING btree (created_by);


--
-- Name: waterbillwatermeterconsume_water_bill_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX waterbillwatermeterconsume_water_bill_id ON public.water_bill_water_meter_consume USING btree (water_bill_id);


--
-- Name: waterbillwatermeterconsume_water_bill_id_water_meter_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX waterbillwatermeterconsume_water_bill_id_water_meter_id ON public.water_bill_water_meter_consume USING btree (water_bill_id, water_meter_id);


--
-- Name: waterbillwatermeterconsume_water_meter_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX waterbillwatermeterconsume_water_meter_id ON public.water_bill_water_meter_consume USING btree (water_meter_id);


--
-- Name: watergridaccount_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watergridaccount_created_by ON public.water_grid_account USING btree (created_by);


--
-- Name: watergridaccount_meter_serial_number; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX watergridaccount_meter_serial_number ON public.water_grid_account USING btree (meter_serial_number);


--
-- Name: watergridaccount_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX watergridaccount_name ON public.water_grid_account USING btree (name);


--
-- Name: watergridaccount_number; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX watergridaccount_number ON public.water_grid_account USING btree (number);


--
-- Name: watergridaccount_service_class_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watergridaccount_service_class_id ON public.water_grid_account USING btree (service_class_id);


--
-- Name: watergridaccount_service_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watergridaccount_service_type_id ON public.water_grid_account USING btree (service_type_id);


--
-- Name: watergridaccount_water_grid_provider_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watergridaccount_water_grid_provider_id ON public.water_grid_account USING btree (water_grid_provider_id);


--
-- Name: watergridaccountglobals_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watergridaccountglobals_created_by ON public.water_grid_account_global_types USING btree (created_by);


--
-- Name: watergridaccountglobals_global_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watergridaccountglobals_global_type_id ON public.water_grid_account_global_types USING btree (global_type_id);


--
-- Name: watergridaccountglobals_water_grid_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watergridaccountglobals_water_grid_account_id ON public.water_grid_account_global_types USING btree (water_grid_account_id);


--
-- Name: watergridaccountglobals_water_grid_account_id_global_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX watergridaccountglobals_water_grid_account_id_global_type_id ON public.water_grid_account_global_types USING btree (water_grid_account_id, global_type_id);


--
-- Name: watergridaccountserviceclass_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watergridaccountserviceclass_created_by ON public.water_grid_account_service_class USING btree (created_by);


--
-- Name: watergridaccountserviceclass_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX watergridaccountserviceclass_name ON public.water_grid_account_service_class USING btree (name);


--
-- Name: watergridaccountserviceglobal_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watergridaccountserviceglobal_created_by ON public.water_grid_account_service_global USING btree (created_by);


--
-- Name: watergridaccountserviceglobal_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX watergridaccountserviceglobal_name ON public.water_grid_account_service_global USING btree (name);


--
-- Name: watergridaccountservicesubtype_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watergridaccountservicesubtype_created_by ON public.water_grid_account_service_sub_type USING btree (created_by);


--
-- Name: watergridaccountservicesubtype_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX watergridaccountservicesubtype_name ON public.water_grid_account_service_sub_type USING btree (name);


--
-- Name: watergridaccountservicetype_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watergridaccountservicetype_created_by ON public.water_grid_account_type USING btree (created_by);


--
-- Name: watergridaccountservicetype_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX watergridaccountservicetype_name ON public.water_grid_account_type USING btree (name);


--
-- Name: watergridaccountsubtypes_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watergridaccountsubtypes_created_by ON public.water_grid_account_sub_types USING btree (created_by);


--
-- Name: watergridaccountsubtypes_sub_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watergridaccountsubtypes_sub_type_id ON public.water_grid_account_sub_types USING btree (sub_type_id);


--
-- Name: watergridaccountsubtypes_water_grid_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watergridaccountsubtypes_water_grid_account_id ON public.water_grid_account_sub_types USING btree (water_grid_account_id);


--
-- Name: watergridaccountsubtypes_water_grid_account_id_sub_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX watergridaccountsubtypes_water_grid_account_id_sub_type_id ON public.water_grid_account_sub_types USING btree (water_grid_account_id, sub_type_id);


--
-- Name: watergridprovider_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watergridprovider_created_by ON public.water_grid_provider USING btree (created_by);


--
-- Name: watergridprovider_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX watergridprovider_name ON public.water_grid_provider USING btree (name);


--
-- Name: watergridunits_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watergridunits_created_by ON public.water_grid_account_units USING btree (created_by);


--
-- Name: watergridunits_unit_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watergridunits_unit_id ON public.water_grid_account_units USING btree (unit_id);


--
-- Name: watergridunits_water_grid_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watergridunits_water_grid_account_id ON public.water_grid_account_units USING btree (water_grid_account_id);


--
-- Name: watergridunits_water_grid_account_id_unit_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX watergridunits_water_grid_account_id_unit_id ON public.water_grid_account_units USING btree (water_grid_account_id, unit_id);


--
-- Name: watergridwatermeters_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watergridwatermeters_created_by ON public.water_grid_water_meters USING btree (created_by);


--
-- Name: watergridwatermeters_water_grid_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watergridwatermeters_water_grid_account_id ON public.water_grid_water_meters USING btree (water_grid_account_id);


--
-- Name: watergridwatermeters_water_grid_account_id_water_meter_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX watergridwatermeters_water_grid_account_id_water_meter_id ON public.water_grid_water_meters USING btree (water_grid_account_id, water_meter_id);


--
-- Name: watergridwatermeters_water_meter_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watergridwatermeters_water_meter_id ON public.water_grid_water_meters USING btree (water_meter_id);


--
-- Name: watermeterunits_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watermeterunits_created_by ON public.water_meter_units USING btree (created_by);


--
-- Name: watermeterunits_unit_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watermeterunits_unit_id ON public.water_meter_units USING btree (unit_id);


--
-- Name: watermeterunits_unit_id_water_meter_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX watermeterunits_unit_id_water_meter_id ON public.water_meter_units USING btree (unit_id, water_meter_id);


--
-- Name: watermeterunits_water_meter_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watermeterunits_water_meter_id ON public.water_meter_units USING btree (water_meter_id);


--
-- Name: watertank_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watertank_created_by ON public.water_tank USING btree (created_by);


--
-- Name: watertank_location_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watertank_location_id ON public.water_tank USING btree (location_id);


--
-- Name: watertank_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX watertank_name ON public.water_tank USING btree (name);


--
-- Name: watertank_style_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watertank_style_id ON public.water_tank USING btree (style_id);


--
-- Name: watertank_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watertank_type_id ON public.water_tank USING btree (type_id);


--
-- Name: watertank_water_source_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watertank_water_source_id ON public.water_tank USING btree (water_source_id);


--
-- Name: watertankstyle_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watertankstyle_created_by ON public.water_tank_style USING btree (created_by);


--
-- Name: watertanktype_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watertanktype_created_by ON public.water_tank_type USING btree (created_by);


--
-- Name: watertankunits_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watertankunits_created_by ON public.water_tank_units USING btree (created_by);


--
-- Name: watertankunits_unit_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watertankunits_unit_id ON public.water_tank_units USING btree (unit_id);


--
-- Name: watertankunits_water_tank_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watertankunits_water_tank_id ON public.water_tank_units USING btree (water_tank_id);


--
-- Name: watertankunits_water_tank_id_unit_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX watertankunits_water_tank_id_unit_id ON public.water_tank_units USING btree (water_tank_id, unit_id);


--
-- Name: watertankwatersensors_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watertankwatersensors_created_by ON public.water_tank_water_sensors USING btree (created_by);


--
-- Name: watertankwatersensors_device_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watertankwatersensors_device_id ON public.device_sensors USING btree (device_id);


--
-- Name: watertankwatersensors_device_id_sensor_id_telemetry_key_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX watertankwatersensors_device_id_sensor_id_telemetry_key_id ON public.device_sensors USING btree (device_id, sensor_id, telemetry_key_id);


--
-- Name: watertankwatersensors_sensor_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watertankwatersensors_sensor_id ON public.device_sensors USING btree (sensor_id);


--
-- Name: watertankwatersensors_telemetry_key_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watertankwatersensors_telemetry_key_id ON public.water_tank_water_sensors USING btree (telemetry_key_id);


--
-- Name: watertankwatersensors_water_sensor_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watertankwatersensors_water_sensor_id ON public.water_tank_water_sensors USING btree (water_sensor_id);


--
-- Name: watertankwatersensors_water_tank_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watertankwatersensors_water_tank_id ON public.water_tank_water_sensors USING btree (water_tank_id);


--
-- Name: watertankwatersensors_water_tank_id_water_sensor_id_tele_8198c9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX watertankwatersensors_water_tank_id_water_sensor_id_tele_8198c9 ON public.water_tank_water_sensors USING btree (water_tank_id, water_sensor_id, telemetry_key_id);


--
-- Name: watertankwatervalves_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watertankwatervalves_created_by ON public.water_tank_water_valves USING btree (created_by);


--
-- Name: watertankwatervalves_water_tank_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watertankwatervalves_water_tank_id ON public.water_tank_water_valves USING btree (water_tank_id);


--
-- Name: watertankwatervalves_water_tank_id_water_valve_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX watertankwatervalves_water_tank_id_water_valve_id ON public.water_tank_water_valves USING btree (water_tank_id, water_valve_id);


--
-- Name: watertankwatervalves_water_valve_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX watertankwatervalves_water_valve_id ON public.water_tank_water_valves USING btree (water_valve_id);


--
-- Name: addresses addresses_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: alarms alarms_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alarms
    ADD CONSTRAINT alarms_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: alarms_severities alarms_severities_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alarms_severities
    ADD CONSTRAINT alarms_severities_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: alarms alarms_severity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alarms
    ADD CONSTRAINT alarms_severity_id_fkey FOREIGN KEY (severity_id) REFERENCES public.alarms_severities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: alarms alarms_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alarms
    ADD CONSTRAINT alarms_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.alarms_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: alarms alarms_variable_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alarms
    ADD CONSTRAINT alarms_variable_id_fkey FOREIGN KEY (variable_id) REFERENCES public.telemetries_dictionaries(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: consumption_categories consumption_categories_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consumption_categories
    ADD CONSTRAINT consumption_categories_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: consumption_categories consumption_categories_facility_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consumption_categories
    ADD CONSTRAINT consumption_categories_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES public.facilities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: consumption_categories_grid_billing_accounts_types consumption_categories_grid_b_grid_billing_account_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consumption_categories_grid_billing_accounts_types
    ADD CONSTRAINT consumption_categories_grid_b_grid_billing_account_type_id_fkey FOREIGN KEY (grid_billing_account_type_id) REFERENCES public.grid_billing_accounts_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: consumption_categories_grid_billing_accounts_types consumption_categories_grid_billin_consumption_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consumption_categories_grid_billing_accounts_types
    ADD CONSTRAINT consumption_categories_grid_billin_consumption_category_id_fkey FOREIGN KEY (consumption_category_id) REFERENCES public.consumption_categories(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: consumption_categories_grid_billing_accounts_types consumption_categories_grid_billing_accounts_ty_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consumption_categories_grid_billing_accounts_types
    ADD CONSTRAINT consumption_categories_grid_billing_accounts_ty_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: contacts contacts_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: contacts contacts_facility_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES public.facilities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: contacts contacts_title_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_title_id_fkey FOREIGN KEY (title_id) REFERENCES public.contacts_titles(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: contacts_titles contacts_titles_facility_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contacts_titles
    ADD CONSTRAINT contacts_titles_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES public.facilities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: device_control_type_icon device_control_type_icon_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_control_type_icon
    ADD CONSTRAINT device_control_type_icon_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: device_controls device_controls_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_controls
    ADD CONSTRAINT device_controls_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: device_controls device_controls_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_controls
    ADD CONSTRAINT device_controls_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.device(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: device_controls device_controls_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_controls
    ADD CONSTRAINT device_controls_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.units(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: device_controls_unit_pinned device_controls_unit_pinned_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_controls_unit_pinned
    ADD CONSTRAINT device_controls_unit_pinned_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.units(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: device device_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device
    ADD CONSTRAINT device_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: device_credentials device_credentials_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_credentials
    ADD CONSTRAINT device_credentials_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.device(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: device device_facility_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device
    ADD CONSTRAINT device_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES public.facilities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: device_sensors device_sensors_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_sensors
    ADD CONSTRAINT device_sensors_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: device_sensors device_sensors_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_sensors
    ADD CONSTRAINT device_sensors_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.device(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: device_sensors device_sensors_sensor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_sensors
    ADD CONSTRAINT device_sensors_sensor_id_fkey FOREIGN KEY (sensor_id) REFERENCES public.device(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: device_sensors device_sensors_telemetry_key_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_sensors
    ADD CONSTRAINT device_sensors_telemetry_key_id_fkey FOREIGN KEY (telemetry_key_id) REFERENCES public.telemetries_dictionaries(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: device device_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device
    ADD CONSTRAINT device_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.devices_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: device device_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device
    ADD CONSTRAINT device_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.units(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: device_users device_users_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_users
    ADD CONSTRAINT device_users_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.device(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: device_users device_users_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_users
    ADD CONSTRAINT device_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: devices_styles devices_styles_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_styles
    ADD CONSTRAINT devices_styles_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.devices_categories(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: devices_styles devices_styles_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_styles
    ADD CONSTRAINT devices_styles_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: devices_types_and_styles devices_types_and_styles_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_types_and_styles
    ADD CONSTRAINT devices_types_and_styles_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: devices_types_and_styles devices_types_and_styles_style_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_types_and_styles
    ADD CONSTRAINT devices_types_and_styles_style_id_fkey FOREIGN KEY (style_id) REFERENCES public.devices_styles(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: devices_types_and_styles devices_types_and_styles_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_types_and_styles
    ADD CONSTRAINT devices_types_and_styles_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.devices_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: devices_types devices_types_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_types
    ADD CONSTRAINT devices_types_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.devices_categories(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: devices_types devices_types_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_types
    ADD CONSTRAINT devices_types_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: devices_units devices_units_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_units
    ADD CONSTRAINT devices_units_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.device(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: devices_units devices_units_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices_units
    ADD CONSTRAINT devices_units_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.units(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: energy_meters energy_meters_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.energy_meters
    ADD CONSTRAINT energy_meters_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: energy_meters energy_meters_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.energy_meters
    ADD CONSTRAINT energy_meters_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.device(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: energy_meters energy_meters_facility_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.energy_meters
    ADD CONSTRAINT energy_meters_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES public.facilities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: energy_meters energy_meters_grid_billing_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.energy_meters
    ADD CONSTRAINT energy_meters_grid_billing_account_id_fkey FOREIGN KEY (grid_billing_account_id) REFERENCES public.grid_billing_accounts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: energy_meters energy_meters_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.energy_meters
    ADD CONSTRAINT energy_meters_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.energy_meters(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: energy_meters energy_meters_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.energy_meters
    ADD CONSTRAINT energy_meters_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.energy_meters_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: energy_meters energy_meters_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.energy_meters
    ADD CONSTRAINT energy_meters_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.units(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facilities facilities_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facilities
    ADD CONSTRAINT facilities_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.addresses(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facilities facilities_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facilities
    ADD CONSTRAINT facilities_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facilities facilities_facility_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facilities
    ADD CONSTRAINT facilities_facility_type_id_fkey FOREIGN KEY (facility_type_id) REFERENCES public.facilities_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facilities facilities_first_emergency_contact_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facilities
    ADD CONSTRAINT facilities_first_emergency_contact_fkey FOREIGN KEY (first_emergency_contact) REFERENCES public.contacts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facilities facilities_maintenance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facilities
    ADD CONSTRAINT facilities_maintenance_id_fkey FOREIGN KEY (maintenance_id) REFERENCES public.facility_maintenance(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facilities facilities_occupancy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facilities
    ADD CONSTRAINT facilities_occupancy_id_fkey FOREIGN KEY (occupancy_id) REFERENCES public.facility_occupancy(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facilities facilities_safety_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facilities
    ADD CONSTRAINT facilities_safety_id_fkey FOREIGN KEY (safety_id) REFERENCES public.facility_safety(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facilities facilities_second_emergency_contact_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facilities
    ADD CONSTRAINT facilities_second_emergency_contact_fkey FOREIGN KEY (second_emergency_contact) REFERENCES public.contacts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facilities facilities_security_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facilities
    ADD CONSTRAINT facilities_security_id_fkey FOREIGN KEY (security_id) REFERENCES public.facility_security(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facilities_types facilities_types_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facilities_types
    ADD CONSTRAINT facilities_types_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facilities facilities_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facilities
    ADD CONSTRAINT facilities_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.units(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facility_maintenance facility_maintenance_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_maintenance
    ADD CONSTRAINT facility_maintenance_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facility_maintenance facility_maintenance_facility_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_maintenance
    ADD CONSTRAINT facility_maintenance_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES public.facilities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facility_maintenance_maintenance_team_trainings facility_maintenance_maintena_maintenance_team_training_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_maintenance_maintenance_team_trainings
    ADD CONSTRAINT facility_maintenance_maintena_maintenance_team_training_id_fkey FOREIGN KEY (maintenance_team_training_id) REFERENCES public.maintenance_team_trainings(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facility_maintenance_maintenance_team_trainings facility_maintenance_maintenance_t_facility_maintenance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_maintenance_maintenance_team_trainings
    ADD CONSTRAINT facility_maintenance_maintenance_t_facility_maintenance_id_fkey FOREIGN KEY (facility_maintenance_id) REFERENCES public.facility_maintenance(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facility_maintenance_maintenance_team_trainings facility_maintenance_maintenance_team_trainings_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_maintenance_maintenance_team_trainings
    ADD CONSTRAINT facility_maintenance_maintenance_team_trainings_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facility_maintenance facility_maintenance_private_maintenance_company_contact_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_maintenance
    ADD CONSTRAINT facility_maintenance_private_maintenance_company_contact_fkey FOREIGN KEY (private_maintenance_company_contact) REFERENCES public.contacts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facility_maintenance facility_maintenance_resident_maintenance_team_contact_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_maintenance
    ADD CONSTRAINT facility_maintenance_resident_maintenance_team_contact_id_fkey FOREIGN KEY (resident_maintenance_team_contact_id) REFERENCES public.contacts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facility_occupancy facility_occupancy_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_occupancy
    ADD CONSTRAINT facility_occupancy_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facility_occupancy facility_occupancy_facility_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_occupancy
    ADD CONSTRAINT facility_occupancy_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES public.facilities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facility_occupancy facility_occupancy_personal_access_permit_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_occupancy
    ADD CONSTRAINT facility_occupancy_personal_access_permit_fkey FOREIGN KEY (personal_access_permit) REFERENCES public.permities_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facility_occupancy facility_occupancy_vehicles_access_permit_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_occupancy
    ADD CONSTRAINT facility_occupancy_vehicles_access_permit_fkey FOREIGN KEY (vehicles_access_permit) REFERENCES public.permities_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facility_occupancy_vehicles_types facility_occupancy_vehicles_types_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_occupancy_vehicles_types
    ADD CONSTRAINT facility_occupancy_vehicles_types_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facility_occupancy_vehicles_types facility_occupancy_vehicles_types_facility_occupancy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_occupancy_vehicles_types
    ADD CONSTRAINT facility_occupancy_vehicles_types_facility_occupancy_id_fkey FOREIGN KEY (facility_occupancy_id) REFERENCES public.facility_occupancy(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facility_occupancy_vehicles_types facility_occupancy_vehicles_types_vehicles_types_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_occupancy_vehicles_types
    ADD CONSTRAINT facility_occupancy_vehicles_types_vehicles_types_id_fkey FOREIGN KEY (vehicles_types_id) REFERENCES public.vehicles_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facility_safety facility_safety_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_safety
    ADD CONSTRAINT facility_safety_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facility_safety facility_safety_facility_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_safety
    ADD CONSTRAINT facility_safety_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES public.facilities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facility_safety facility_safety_fire_alarm_system_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_safety
    ADD CONSTRAINT facility_safety_fire_alarm_system_type_id_fkey FOREIGN KEY (fire_alarm_system_type_id) REFERENCES public.fire_alarm_systems_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facility_safety facility_safety_hazardous_materials_officer_contact_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_safety
    ADD CONSTRAINT facility_safety_hazardous_materials_officer_contact_id_fkey FOREIGN KEY (hazardous_materials_officer_contact_id) REFERENCES public.contacts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facility_safety facility_safety_resident_safety_inspector_contact_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_safety
    ADD CONSTRAINT facility_safety_resident_safety_inspector_contact_id_fkey FOREIGN KEY (resident_safety_inspector_contact_id) REFERENCES public.contacts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facility_security facility_security_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_security
    ADD CONSTRAINT facility_security_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facility_security facility_security_facility_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_security
    ADD CONSTRAINT facility_security_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES public.facilities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: facility_security facility_security_private_security_company_contact_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility_security
    ADD CONSTRAINT facility_security_private_security_company_contact_id_fkey FOREIGN KEY (private_security_company_contact_id) REFERENCES public.contacts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: grid_billing_accounts grid_billing_accounts_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grid_billing_accounts
    ADD CONSTRAINT grid_billing_accounts_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: grid_billing_accounts grid_billing_accounts_facility_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grid_billing_accounts
    ADD CONSTRAINT grid_billing_accounts_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES public.facilities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: grid_billing_accounts grid_billing_accounts_service_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grid_billing_accounts
    ADD CONSTRAINT grid_billing_accounts_service_class_id_fkey FOREIGN KEY (service_class_id) REFERENCES public.grid_billing_accounts_service_classes(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: grid_billing_accounts_service_classes grid_billing_accounts_service_classes_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grid_billing_accounts_service_classes
    ADD CONSTRAINT grid_billing_accounts_service_classes_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: grid_billing_accounts_service_classes grid_billing_accounts_service_classes_facility_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grid_billing_accounts_service_classes
    ADD CONSTRAINT grid_billing_accounts_service_classes_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES public.facilities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: grid_billing_accounts grid_billing_accounts_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grid_billing_accounts
    ADD CONSTRAINT grid_billing_accounts_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.grid_billing_accounts_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: main_energy_meters main_energy_meters_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.main_energy_meters
    ADD CONSTRAINT main_energy_meters_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.grid_billing_accounts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: main_energy_meters main_energy_meters_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.main_energy_meters
    ADD CONSTRAINT main_energy_meters_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: maintenance_team_trainings maintenance_team_trainings_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_team_trainings
    ADD CONSTRAINT maintenance_team_trainings_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: maintenance_team_trainings maintenance_team_trainings_facility_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maintenance_team_trainings
    ADD CONSTRAINT maintenance_team_trainings_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES public.facilities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: menus_and_roles menus_and_roles_menu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menus_and_roles
    ADD CONSTRAINT menus_and_roles_menu_id_fkey FOREIGN KEY (menu_id) REFERENCES public.menus(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: menus_and_roles menus_and_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menus_and_roles
    ADD CONSTRAINT menus_and_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: menus menus_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menus
    ADD CONSTRAINT menus_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.menus(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: multi_factor_authentication_factors multi_factor_authentication_factors_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.multi_factor_authentication_factors
    ADD CONSTRAINT multi_factor_authentication_factors_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: multi_factor_authentication_factors multi_factor_authentication_factors_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.multi_factor_authentication_factors
    ADD CONSTRAINT multi_factor_authentication_factors_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.multi_factor_authentication_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: permissions permissions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: permities_types permities_types_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permities_types
    ADD CONSTRAINT permities_types_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: permities_types permities_types_facility_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permities_types
    ADD CONSTRAINT permities_types_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES public.facilities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: roles_and_permissions roles_and_permissions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles_and_permissions
    ADD CONSTRAINT roles_and_permissions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: roles_and_permissions roles_and_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles_and_permissions
    ADD CONSTRAINT roles_and_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: roles_and_permissions roles_and_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles_and_permissions
    ADD CONSTRAINT roles_and_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: roles roles_facility_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES public.facilities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: scheduled_controls scheduled_controls_control_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scheduled_controls
    ADD CONSTRAINT scheduled_controls_control_id_fkey FOREIGN KEY (control_id) REFERENCES public.device_controls(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: scheduled_controls scheduled_controls_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scheduled_controls
    ADD CONSTRAINT scheduled_controls_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.device(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: scheduled_controls scheduled_controls_facility_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scheduled_controls
    ADD CONSTRAINT scheduled_controls_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES public.facilities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: scheduled_controls scheduled_controls_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scheduled_controls
    ADD CONSTRAINT scheduled_controls_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.units(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sub_energy_meters sub_energy_meters_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sub_energy_meters
    ADD CONSTRAINT sub_energy_meters_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sub_energy_meters sub_energy_meters_main_meter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sub_energy_meters
    ADD CONSTRAINT sub_energy_meters_main_meter_id_fkey FOREIGN KEY (main_meter_id) REFERENCES public.main_energy_meters(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tariff_categories tariff_categories_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tariff_categories
    ADD CONSTRAINT tariff_categories_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tariff_categories tariff_categories_facility_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tariff_categories
    ADD CONSTRAINT tariff_categories_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES public.facilities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tariff_categories_service_classes tariff_categories_service_classes_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tariff_categories_service_classes
    ADD CONSTRAINT tariff_categories_service_classes_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tariff_categories_service_classes tariff_categories_service_classes_service_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tariff_categories_service_classes
    ADD CONSTRAINT tariff_categories_service_classes_service_class_id_fkey FOREIGN KEY (service_class_id) REFERENCES public.grid_billing_accounts_service_classes(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tariff_categories_service_classes tariff_categories_service_classes_tariff_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tariff_categories_service_classes
    ADD CONSTRAINT tariff_categories_service_classes_tariff_category_id_fkey FOREIGN KEY (tariff_category_id) REFERENCES public.tariff_categories(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: telemetries telemetries_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telemetries
    ADD CONSTRAINT telemetries_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.device(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: telemetries_log telemetries_log_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telemetries_log
    ADD CONSTRAINT telemetries_log_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.device(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: telemetries_notif telemetries_notif_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telemetries_notif
    ADD CONSTRAINT telemetries_notif_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.device(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: telemetries_notif_users telemetries_notif_users_notif_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telemetries_notif_users
    ADD CONSTRAINT telemetries_notif_users_notif_id_fkey FOREIGN KEY (notif_id) REFERENCES public.telemetries_notif(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: telemetries_notif_users telemetries_notif_users_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telemetries_notif_users
    ADD CONSTRAINT telemetries_notif_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: units units_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: units units_facility_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES public.facilities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: units units_icon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_icon_id_fkey FOREIGN KEY (icon_id) REFERENCES public.icons(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: units units_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.units(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: units units_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.units_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: units_types units_types_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.units_types
    ADD CONSTRAINT units_types_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: units_types units_types_facility_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.units_types
    ADD CONSTRAINT units_types_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES public.facilities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: units_types units_types_icon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.units_types
    ADD CONSTRAINT units_types_icon_id_fkey FOREIGN KEY (icon_id) REFERENCES public.icons(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users_and_buildings users_and_buildings_building_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_and_buildings
    ADD CONSTRAINT users_and_buildings_building_id_fkey FOREIGN KEY (building_id) REFERENCES public.units(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users_and_buildings users_and_buildings_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_and_buildings
    ADD CONSTRAINT users_and_buildings_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users_and_buildings users_and_buildings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_and_buildings
    ADD CONSTRAINT users_and_buildings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users users_facility_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES public.facilities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users users_mfa_factor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_mfa_factor_id_fkey FOREIGN KEY (mfa_factor_id) REFERENCES public.multi_factor_authentication_factors(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: vehicles_types vehicles_types_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicles_types
    ADD CONSTRAINT vehicles_types_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_bill water_bill_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_bill
    ADD CONSTRAINT water_bill_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_bill water_bill_water_grid_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_bill
    ADD CONSTRAINT water_bill_water_grid_account_id_fkey FOREIGN KEY (water_grid_account_id) REFERENCES public.water_grid_account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_bill_water_meter_consume water_bill_water_meter_consume_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_bill_water_meter_consume
    ADD CONSTRAINT water_bill_water_meter_consume_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_bill_water_meter_consume water_bill_water_meter_consume_water_bill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_bill_water_meter_consume
    ADD CONSTRAINT water_bill_water_meter_consume_water_bill_id_fkey FOREIGN KEY (water_bill_id) REFERENCES public.water_bill(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_bill_water_meter_consume water_bill_water_meter_consume_water_meter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_bill_water_meter_consume
    ADD CONSTRAINT water_bill_water_meter_consume_water_meter_id_fkey FOREIGN KEY (water_meter_id) REFERENCES public.device(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_grid_account water_grid_account_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_account
    ADD CONSTRAINT water_grid_account_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_grid_account_global_types water_grid_account_global_types_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_account_global_types
    ADD CONSTRAINT water_grid_account_global_types_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_grid_account_global_types water_grid_account_global_types_global_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_account_global_types
    ADD CONSTRAINT water_grid_account_global_types_global_type_id_fkey FOREIGN KEY (global_type_id) REFERENCES public.water_grid_account_service_global(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_grid_account_global_types water_grid_account_global_types_water_grid_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_account_global_types
    ADD CONSTRAINT water_grid_account_global_types_water_grid_account_id_fkey FOREIGN KEY (water_grid_account_id) REFERENCES public.water_grid_account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_grid_account_service_class water_grid_account_service_class_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_account_service_class
    ADD CONSTRAINT water_grid_account_service_class_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_grid_account water_grid_account_service_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_account
    ADD CONSTRAINT water_grid_account_service_class_id_fkey FOREIGN KEY (service_class_id) REFERENCES public.water_grid_account_service_class(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_grid_account_service_global water_grid_account_service_global_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_account_service_global
    ADD CONSTRAINT water_grid_account_service_global_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_grid_account_service_sub_type water_grid_account_service_sub_type_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_account_service_sub_type
    ADD CONSTRAINT water_grid_account_service_sub_type_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_grid_account water_grid_account_service_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_account
    ADD CONSTRAINT water_grid_account_service_type_id_fkey FOREIGN KEY (service_type_id) REFERENCES public.water_grid_account_type(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_grid_account_sub_types water_grid_account_sub_types_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_account_sub_types
    ADD CONSTRAINT water_grid_account_sub_types_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_grid_account_sub_types water_grid_account_sub_types_sub_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_account_sub_types
    ADD CONSTRAINT water_grid_account_sub_types_sub_type_id_fkey FOREIGN KEY (sub_type_id) REFERENCES public.water_grid_account_service_sub_type(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_grid_account_sub_types water_grid_account_sub_types_water_grid_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_account_sub_types
    ADD CONSTRAINT water_grid_account_sub_types_water_grid_account_id_fkey FOREIGN KEY (water_grid_account_id) REFERENCES public.water_grid_account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_grid_account_type water_grid_account_type_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_account_type
    ADD CONSTRAINT water_grid_account_type_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_grid_account_units water_grid_account_units_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_account_units
    ADD CONSTRAINT water_grid_account_units_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_grid_account_units water_grid_account_units_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_account_units
    ADD CONSTRAINT water_grid_account_units_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.units(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_grid_account_units water_grid_account_units_water_grid_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_account_units
    ADD CONSTRAINT water_grid_account_units_water_grid_account_id_fkey FOREIGN KEY (water_grid_account_id) REFERENCES public.water_grid_account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_grid_account water_grid_account_water_grid_provider_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_account
    ADD CONSTRAINT water_grid_account_water_grid_provider_id_fkey FOREIGN KEY (water_grid_provider_id) REFERENCES public.water_grid_provider(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_grid_provider water_grid_provider_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_provider
    ADD CONSTRAINT water_grid_provider_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_grid_water_meters water_grid_water_meters_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_water_meters
    ADD CONSTRAINT water_grid_water_meters_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_grid_water_meters water_grid_water_meters_water_grid_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_water_meters
    ADD CONSTRAINT water_grid_water_meters_water_grid_account_id_fkey FOREIGN KEY (water_grid_account_id) REFERENCES public.water_grid_account(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_grid_water_meters water_grid_water_meters_water_meter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_grid_water_meters
    ADD CONSTRAINT water_grid_water_meters_water_meter_id_fkey FOREIGN KEY (water_meter_id) REFERENCES public.device(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_meter_units water_meter_units_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_meter_units
    ADD CONSTRAINT water_meter_units_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_meter_units water_meter_units_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_meter_units
    ADD CONSTRAINT water_meter_units_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.units(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_meter_units water_meter_units_water_meter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_meter_units
    ADD CONSTRAINT water_meter_units_water_meter_id_fkey FOREIGN KEY (water_meter_id) REFERENCES public.device(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_tank water_tank_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_tank
    ADD CONSTRAINT water_tank_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_tank water_tank_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_tank
    ADD CONSTRAINT water_tank_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.units(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_tank_style water_tank_style_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_tank_style
    ADD CONSTRAINT water_tank_style_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_tank water_tank_style_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_tank
    ADD CONSTRAINT water_tank_style_id_fkey FOREIGN KEY (style_id) REFERENCES public.water_tank_style(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_tank_type water_tank_type_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_tank_type
    ADD CONSTRAINT water_tank_type_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_tank water_tank_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_tank
    ADD CONSTRAINT water_tank_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.water_tank_type(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_tank_units water_tank_units_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_tank_units
    ADD CONSTRAINT water_tank_units_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_tank_units water_tank_units_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_tank_units
    ADD CONSTRAINT water_tank_units_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.units(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_tank_units water_tank_units_water_tank_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_tank_units
    ADD CONSTRAINT water_tank_units_water_tank_id_fkey FOREIGN KEY (water_tank_id) REFERENCES public.water_tank(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_tank_water_sensors water_tank_water_sensors_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_tank_water_sensors
    ADD CONSTRAINT water_tank_water_sensors_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_tank_water_sensors water_tank_water_sensors_telemetry_key_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_tank_water_sensors
    ADD CONSTRAINT water_tank_water_sensors_telemetry_key_id_fkey FOREIGN KEY (telemetry_key_id) REFERENCES public.telemetries_dictionaries(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_tank_water_sensors water_tank_water_sensors_water_sensor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_tank_water_sensors
    ADD CONSTRAINT water_tank_water_sensors_water_sensor_id_fkey FOREIGN KEY (water_sensor_id) REFERENCES public.device(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_tank_water_sensors water_tank_water_sensors_water_tank_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_tank_water_sensors
    ADD CONSTRAINT water_tank_water_sensors_water_tank_id_fkey FOREIGN KEY (water_tank_id) REFERENCES public.water_tank(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_tank water_tank_water_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_tank
    ADD CONSTRAINT water_tank_water_source_id_fkey FOREIGN KEY (water_source_id) REFERENCES public.device(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_tank_water_valves water_tank_water_valves_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_tank_water_valves
    ADD CONSTRAINT water_tank_water_valves_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_tank_water_valves water_tank_water_valves_water_tank_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_tank_water_valves
    ADD CONSTRAINT water_tank_water_valves_water_tank_id_fkey FOREIGN KEY (water_tank_id) REFERENCES public.water_tank(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_tank_water_valves water_tank_water_valves_water_valve_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.water_tank_water_valves
    ADD CONSTRAINT water_tank_water_valves_water_valve_id_fkey FOREIGN KEY (water_valve_id) REFERENCES public.device(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

