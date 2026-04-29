import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../database/database.dart';
import 'taller_config_service.dart';

class ComprobanteService {
  /// Genera y muestra el diálogo de impresión/guardado.
  /// Una hoja A4 con dos copias: CLIENTE (arriba) y TALLER (abajo).
  static Future<void> generarYMostrarComprobante({
    required OrdenCompleta ordenCompleta,
  }) async {
    // Leer config del taller en tiempo real
    final config = await TallerConfigService.cargar();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.fromLTRB(30, 24, 30, 12),
                  child: _buildCuerpo(
                    ordenCompleta: ordenCompleta,
                    config: config,
                    etiquetaCopia: 'COPIA CLIENTE',
                  ),
                ),
              ),
              _buildLineaDeCorte(),
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.fromLTRB(30, 12, 30, 24),
                  child: _buildCuerpo(
                    ordenCompleta: ordenCompleta,
                    config: config,
                    etiquetaCopia: 'COPIA TALLER',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Comprobante_Orden_${ordenCompleta.orden.id}',
    );
  }

  // ── CUERPO DE CADA COPIA ──────────────────────────────────────────────────
  static pw.Widget _buildCuerpo({
    required OrdenCompleta ordenCompleta,
    required TallerConfig config,
    required String etiquetaCopia,
  }) {
    final orden   = ordenCompleta.orden;
    final equipo  = ordenCompleta.equipo;
    final cliente = ordenCompleta.cliente;
    final fmt     = DateFormat('dd/MM/yyyy HH:mm');

    const colorPrimario    = PdfColor.fromInt(0xFF1565C0);
    const colorFondoHeader = PdfColor.fromInt(0xFFE3F2FD);
    const colorLinea       = PdfColor.fromInt(0xFFBBDEFB);
    const colorTextoGris   = PdfColor.fromInt(0xFF757575);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // ── HEADER ──
        pw.Container(
          decoration: const pw.BoxDecoration(
            color: colorFondoHeader,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Datos del taller
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (config.nombre.isNotEmpty)
                    pw.Text(
                      config.nombre,
                      style: pw.TextStyle(
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                        color: colorPrimario,
                      ),
                    )
                  else
                    pw.Text(
                      'Taller sin configurar',
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0xFFBDBDBD),
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  if (config.direccion.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(config.direccion,
                        style: const pw.TextStyle(fontSize: 8, color: colorTextoGris)),
                  ],
                  if (config.telefono.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text('Tel: ${config.telefono}',
                        style: const pw.TextStyle(fontSize: 8, color: colorTextoGris)),
                  ],
                  if (config.email.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(config.email,
                        style: const pw.TextStyle(fontSize: 8, color: colorTextoGris)),
                  ],
                  if (config.cuit.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text('CUIT: ${config.cuit}',
                        style: const pw.TextStyle(fontSize: 8, color: colorTextoGris)),
                  ],
                ],
              ),
              // Número de orden + copia
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: const pw.BoxDecoration(
                      color: colorPrimario,
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text(
                      'ORDEN #${orden.id}',
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    etiquetaCopia,
                    style: pw.TextStyle(
                      fontSize: 7,
                      fontWeight: pw.FontWeight.bold,
                      color: colorPrimario,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    _estadoLabel(orden.estado),
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: _colorEstadoPdf(orden.estado),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 10),

        // ── CLIENTE ──
        _buildSeccion(
          titulo: 'DATOS DEL CLIENTE',
          colorLinea: colorLinea,
          filas: [
            _fila('Nombre', cliente.nombre),
            if (cliente.telefono != null) _fila('Teléfono', cliente.telefono!),
            if (cliente.email != null) _fila('Email', cliente.email!),
            if (cliente.direccion != null) _fila('Dirección', cliente.direccion!),
          ],
        ),

        pw.SizedBox(height: 8),

        // ── EQUIPO ──
        _buildSeccion(
          titulo: 'DATOS DEL EQUIPO',
          colorLinea: colorLinea,
          filas: [
            _fila('Tipo', equipo.tipo),
            if (equipo.marca != null) _fila('Marca', equipo.marca!),
            if (equipo.modelo != null) _fila('Modelo', equipo.modelo!),
            if (equipo.numeroSerie != null) _fila('N° de Serie', equipo.numeroSerie!),
          ],
        ),

        pw.SizedBox(height: 8),

        // ── SERVICIO ──
        _buildSeccion(
          titulo: 'DETALLE DEL SERVICIO',
          colorLinea: colorLinea,
          filas: [
            _fila('Fecha de ingreso', fmt.format(orden.fechaIngreso)),
            if (orden.fechaEntrega != null)
              _fila('Fecha de entrega', fmt.format(orden.fechaEntrega!)),
            if (orden.diagnostico != null && orden.diagnostico!.isNotEmpty)
              _filaMultilinea('Diagnóstico', orden.diagnostico!),
            if (orden.solucion != null && orden.solucion!.isNotEmpty)
              _filaMultilinea('Solución', orden.solucion!),
            if (orden.observaciones != null && orden.observaciones!.isNotEmpty)
              _filaMultilinea('Observaciones', orden.observaciones!),
          ],
        ),

        pw.Spacer(),

        // ── PIE: COSTO + FIRMA ──
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Expanded(
              flex: 3,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: const pw.BoxDecoration(
                      color: colorPrimario,
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'TOTAL A PAGAR',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.Text(
                          '\$${orden.costo.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Formas de pago: Efectivo / Transferencia',
                    style: const pw.TextStyle(fontSize: 7, color: colorTextoGris),
                  ),
                ],
              ),
            ),
            pw.SizedBox(width: 16),
            pw.Expanded(
              flex: 2,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    height: 28,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(color: colorTextoGris, width: 0.5),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'Firma y aclaración del cliente',
                    style: const pw.TextStyle(fontSize: 7, color: colorTextoGris),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),

        pw.SizedBox(height: 6),

        // Nota al pie (de la configuración o genérica)
        pw.Text(
          config.notas.isNotEmpty
              ? config.notas
              : 'Conservá este comprobante para retirar el equipo.',
          style: pw.TextStyle(
            fontSize: 7,
            color: colorTextoGris,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
      ],
    );
  }

  // ── LÍNEA DE CORTE ────────────────────────────────────────────────────────
  static pw.Widget _buildLineaDeCorte() {
    return pw.Row(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8),
          child: pw.Text('✂', style: const pw.TextStyle(fontSize: 10)),
        ),
        pw.Expanded(
          child: pw.Container(
            height: 1,
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(
                  color: PdfColor.fromInt(0xFF9E9E9E),
                  width: 0.5,
                  style: pw.BorderStyle.dashed,
                ),
              ),
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8),
          child: pw.Text('✂', style: const pw.TextStyle(fontSize: 10)),
        ),
      ],
    );
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────
  static pw.Widget _buildSeccion({
    required String titulo,
    required PdfColor colorLinea,
    required List<pw.Widget> filas,
  }) {
    const colorPrimario = PdfColor.fromInt(0xFF1565C0);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Container(
              width: 3, height: 12,
              decoration: const pw.BoxDecoration(
                color: colorPrimario,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
              ),
            ),
            pw.SizedBox(width: 6),
            pw.Text(
              titulo,
              style: pw.TextStyle(
                  fontSize: 8, fontWeight: pw.FontWeight.bold, color: colorPrimario),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: colorLinea, width: 0.5),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          padding: const pw.EdgeInsets.all(8),
          child: pw.Column(children: filas),
        ),
      ],
    );
  }

  static pw.Widget _fila(String label, String valor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 70,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: const PdfColor.fromInt(0xFF424242),
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(valor, style: const pw.TextStyle(fontSize: 8)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _filaMultilinea(String label, String valor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '$label:',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: const PdfColor.fromInt(0xFF424242),
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(valor, style: const pw.TextStyle(fontSize: 8)),
        ],
      ),
    );
  }

  static String _estadoLabel(String estado) {
    switch (estado) {
      case 'pendiente':   return '● PENDIENTE';
      case 'en_proceso':  return '● EN PROCESO';
      case 'finalizada':  return '● FINALIZADA';
      case 'entregada':   return '● ENTREGADA';
      default:            return estado.toUpperCase();
    }
  }

  static PdfColor _colorEstadoPdf(String estado) {
    switch (estado) {
      case 'pendiente':   return const PdfColor.fromInt(0xFFE65100);
      case 'en_proceso':  return const PdfColor.fromInt(0xFF0D47A1);
      case 'finalizada':  return const PdfColor.fromInt(0xFF1B5E20);
      case 'entregada':   return const PdfColor.fromInt(0xFF616161);
      default:            return PdfColors.grey;
    }
  }
}