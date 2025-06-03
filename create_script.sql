-- Remove conflicting tables
DROP TABLE IF EXISTS hrac CASCADE;
DROP TABLE IF EXISTS klub CASCADE;
DROP TABLE IF EXISTS klub_trofej CASCADE;
DROP TABLE IF EXISTS kontrakt CASCADE;
DROP TABLE IF EXISTS liga CASCADE;
DROP TABLE IF EXISTS stadion CASCADE;
DROP TABLE IF EXISTS trener CASCADE;
DROP TABLE IF EXISTS trofej CASCADE;
DROP TABLE IF EXISTS zapas CASCADE;
DROP TABLE IF EXISTS zapas_hrac CASCADE;
-- End of removing

CREATE TABLE hrac (
    id_hrac SERIAL NOT NULL,
    jmeno VARCHAR(256) NOT NULL,
    prijmeni VARCHAR(256) NOT NULL,
    datum_narozeni DATE NOT NULL,
    narodnost VARCHAR(256) NOT NULL,
    pozice VARCHAR(256) NOT NULL
);
ALTER TABLE hrac ADD CONSTRAINT pk_hrac PRIMARY KEY (id_hrac);

CREATE TABLE klub (
    id_klub SERIAL NOT NULL,
    id_liga INTEGER,
    nazev VARCHAR(256) NOT NULL
);
ALTER TABLE klub ADD CONSTRAINT pk_klub PRIMARY KEY (id_klub);
ALTER TABLE klub ADD CONSTRAINT uc_klub_nazev UNIQUE (nazev);

CREATE TABLE klub_trofej (
    id_klub INTEGER NOT NULL,
    id_trofej INTEGER NOT NULL,
    pocet INTEGER NOT NULL
);
ALTER TABLE klub_trofej ADD CONSTRAINT pk_klub_trofej PRIMARY KEY (id_klub, id_trofej);

-- Warning: Missing primary key. It is recommended to explicitly define a primary key.
CREATE TABLE kontrakt (
    id_klub INTEGER NOT NULL,
    id_hrac INTEGER,
    id_trener INTEGER,
    zacatek_kontraktu DATE NOT NULL,
    konec_kontraktu DATE NOT NULL
);

CREATE TABLE liga (
    id_liga SERIAL NOT NULL,
    nazev VARCHAR(256) NOT NULL,
    zeme VARCHAR(256) NOT NULL
);
ALTER TABLE liga ADD CONSTRAINT pk_liga PRIMARY KEY (id_liga);

CREATE TABLE stadion (
    id_klub INTEGER NOT NULL,
    nazev VARCHAR(256) NOT NULL,
    kapacita INTEGER NOT NULL
);
ALTER TABLE stadion ADD CONSTRAINT pk_stadion PRIMARY KEY (id_klub);

CREATE TABLE trener (
    id_trener SERIAL NOT NULL,
    jmeno VARCHAR(256) NOT NULL,
    prijmeni VARCHAR(256) NOT NULL,
    datum_narozeni DATE NOT NULL,
    narodnost VARCHAR(256) NOT NULL
);
ALTER TABLE trener ADD CONSTRAINT pk_trener PRIMARY KEY (id_trener);

CREATE TABLE trofej (
    id_trofej SERIAL NOT NULL,
    nazev VARCHAR(256) NOT NULL
);
ALTER TABLE trofej ADD CONSTRAINT pk_trofej PRIMARY KEY (id_trofej);

CREATE TABLE zapas (
    id_zapas SERIAL NOT NULL,
    id_domaci_klub INTEGER NOT NULL,
    id_hostujici_klub INTEGER NOT NULL,
    datum_zapasu DATE NOT NULL
);
ALTER TABLE zapas ADD CONSTRAINT pk_zapas PRIMARY KEY (id_zapas);

CREATE TABLE zapas_hrac (
    id_zapas INTEGER NOT NULL,
    id_hrac INTEGER NOT NULL,
    gol INTEGER,
    asistence INTEGER,
    zluta_karta INTEGER,
    cervena_karta INTEGER
);
ALTER TABLE zapas_hrac ADD CONSTRAINT pk_zapas_hrac PRIMARY KEY (id_zapas, id_hrac);

ALTER TABLE klub ADD CONSTRAINT fk_klub_liga FOREIGN KEY (id_liga) REFERENCES liga (id_liga) ON DELETE CASCADE;

ALTER TABLE klub_trofej ADD CONSTRAINT fk_klub_trofej_klub FOREIGN KEY (id_klub) REFERENCES klub (id_klub) ON DELETE CASCADE;
ALTER TABLE klub_trofej ADD CONSTRAINT fk_klub_trofej_trofej FOREIGN KEY (id_trofej) REFERENCES trofej (id_trofej) ON DELETE CASCADE;

ALTER TABLE kontrakt ADD CONSTRAINT fk_kontrakt_klub FOREIGN KEY (id_klub) REFERENCES klub (id_klub) ON DELETE CASCADE;
ALTER TABLE kontrakt ADD CONSTRAINT fk_kontrakt_hrac FOREIGN KEY (id_hrac) REFERENCES hrac (id_hrac) ON DELETE CASCADE;
ALTER TABLE kontrakt ADD CONSTRAINT fk_kontrakt_trener FOREIGN KEY (id_trener) REFERENCES trener (id_trener) ON DELETE CASCADE;

ALTER TABLE stadion ADD CONSTRAINT fk_stadion_klub FOREIGN KEY (id_klub) REFERENCES klub (id_klub) ON DELETE CASCADE;

ALTER TABLE zapas ADD CONSTRAINT fk_zapas_domaci FOREIGN KEY (id_domaci_klub) REFERENCES klub (id_klub) ON DELETE CASCADE;
ALTER TABLE zapas ADD CONSTRAINT fk_zapas_hostujici FOREIGN KEY (id_hostujici_klub) REFERENCES klub (id_klub) ON DELETE CASCADE;
ALTER TABLE zapas ADD CONSTRAINT chk_zapas_kluby CHECK (id_domaci_klub <> id_hostujici_klub);

ALTER TABLE zapas_hrac ADD CONSTRAINT fk_zapas_hrac_zapas FOREIGN KEY (id_zapas) REFERENCES zapas (id_zapas) ON DELETE CASCADE;
ALTER TABLE zapas_hrac ADD CONSTRAINT fk_zapas_hrac_hrac FOREIGN KEY (id_hrac) REFERENCES hrac (id_hrac) ON DELETE CASCADE;

ALTER TABLE kontrakt ADD CONSTRAINT xc_kontrakt_id_hrac_id_trener CHECK ((id_hrac IS NOT NULL AND id_trener IS NULL) OR (id_hrac IS NULL AND id_trener IS NOT NULL));
