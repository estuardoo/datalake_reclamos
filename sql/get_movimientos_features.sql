CREATE SCHEMA IF NOT EXISTS analytics;

CREATE TABLE analytics.movimientos_aprobados_ml AS
SELECT
  -- transacción
  t.monto,
  t.fecha_operacion,
  t.id_canal,
  canal.codigo  AS canal_codigo,
  canal.nombre  AS canal_nombre,
  t.id_comercio,
  com.ruc       AS comercio_ruc,
  com.nombre    AS comercio_nombre,
  com.pais_iso2 AS comercio_pais_iso2,
  com.ciudad    AS comercio_ciudad,
  com.mcc       AS mcc_codigo,
  mcc.nombre    AS mcc_nombre,
  t.id_tarjeta,
  t.id_moneda,
  mon.codigo    AS moneda_codigo,
  mon.nombre    AS moneda_nombre,

  -- atributos de tarjeta
  prod.codigo   AS tarjeta_producto_codigo,
  prod.nombre   AS tarjeta_producto_nombre,
  red.codigo    AS tarjeta_red_codigo,
  red.nombre    AS tarjeta_red_nombre,
  est.codigo    AS tarjeta_estado_codigo,
  est.nombre    AS tarjeta_estado_nombre,
  mon_t.codigo  AS tarjeta_moneda_codigo,
  mon_t.nombre  AS tarjeta_moneda_nombre

FROM core_movimientos.transaccion t
LEFT JOIN core_movimientos.cat_canal_tx canal
  ON canal.id_canal = t.id_canal
LEFT JOIN core_movimientos.cat_moneda mon
  ON mon.id_moneda = t.id_moneda
LEFT JOIN core_movimientos.comercio com
  ON com.id_comercio = t.id_comercio
LEFT JOIN core_movimientos.cat_mcc mcc
  ON mcc.mcc = com.mcc
LEFT JOIN core_tarjetas.tarjeta tar
  ON tar.id_tarjeta = t.id_tarjeta
LEFT JOIN core_tarjetas.cat_producto_tarjeta prod
  ON prod.id_producto = tar.id_producto
LEFT JOIN core_tarjetas.cat_red_tarjeta red
  ON red.id_red = tar.id_red
LEFT JOIN core_tarjetas.cat_estado_tarjeta est
  ON est.id_estado = tar.id_estado
LEFT JOIN core_tarjetas.cat_moneda mon_t
  ON mon_t.id_moneda = tar.id_moneda
WHERE t.estado = 'APROBADO';

CREATE INDEX IF NOT EXISTS ix_ml_tarjeta_fecha
  ON analytics.movimientos_aprobados_ml (id_tarjeta, fecha_operacion);