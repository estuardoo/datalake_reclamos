CREATE DATABASE IF NOT EXISTS datalake_db;

CREATE EXTERNAL TABLE IF NOT EXISTS datalake_db.reclamos_ml (
  id_reclamo BIGINT,
  id_cliente INT,
  id_tarjeta INT,
  tipo_codigo STRING,
  tipo_nombre STRING,
  criticidad STRING,
  estado_codigo STRING,
  estado_nombre STRING,
  canal_codigo STRING,
  canal_nombre STRING,
  descripcion STRING,
  monto DOUBLE,
  moneda_codigo STRING,
  fecha_apertura STRING,
  fecha_cierre STRING,
  sla_dias INT,
  dias_transcurridos INT,
  en_sla BOOLEAN,
  referencia_externa STRING,
  movimientos_count INT,
  ultimo_id_movimiento BIGINT,
  decision_resultado STRING,
  decision_monto_reintegrar DOUBLE,
  decision_fecha_decision STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar'     = '"'
)
LOCATION 's3://datalake-estuardoo-prod/raw/reclamos/'
TBLPROPERTIES ('skip.header.line.count'='1');
