import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AcercaDeScreen extends StatefulWidget {
  const AcercaDeScreen({super.key});

  @override
  State<AcercaDeScreen> createState() => _AcercaDeScreenState();
}

class _AcercaDeScreenState extends State<AcercaDeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  bool _emailCopiado = false;

  static const _email = 'segurajavier730@gmail.com';
  static const _portfolio = 'https://mauri01.github.io/portfolio/';
  static const _instagram = 'https://instagram.com/mau_developer';
  static const _youtube = 'https://www.youtube.com/channel/UCvSBVjSUY5qKqZ7Gz4A-uvA';
  static const _tiktok = 'https://tiktok.com/@maudeveloper';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _abrirUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _copiarEmail() async {
    await Clipboard.setData(const ClipboardData(text: _email));
    setState(() => _emailCopiado = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _emailCopiado = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        title: const Text(
          'Acerca del desarrollador',
          style: TextStyle(color: Colors.white70, fontSize: 15),
        ),
        iconTheme: const IconThemeData(color: Colors.white54),
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: SlideTransition(
          position: _slideUp,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // ── PERFIL ──────────────────────────────────────────────
                    _buildPerfil(),
                    const SizedBox(height: 36),

                    // ── MENSAJE PERSONAL ────────────────────────────────────
                    _buildMensaje(),
                    const SizedBox(height: 32),

                    // ── CONTACTO ────────────────────────────────────────────
                    _buildContacto(),
                    const SizedBox(height: 32),

                    // ── REDES ────────────────────────────────────────────────
                    _buildRedes(),
                    const SizedBox(height: 40),

                    // ── PIE ──────────────────────────────────────────────────
                    _buildPie(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── PERFIL ─────────────────────────────────────────────────────────────────
  Widget _buildPerfil() {
    return Column(
      children: [
        // Avatar con borde luminoso
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF3ECFCF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.4),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(3),
          child: ClipOval(
            child: Image.network(
              'https://mauri01.github.io/portfolio/assets/profile.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF1E1E1E),
                child: const Icon(Icons.person, color: Colors.white54, size: 48),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Mau Developer',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Desarrollador Mobile & Creator',
          style: TextStyle(
            color: Color(0xFF3ECFCF),
            fontSize: 13,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: 16),

        // Botón portfolio
        OutlinedButton.icon(
          onPressed: () => _abrirUrl(_portfolio),
          icon: const Text('🌐', style: TextStyle(fontSize: 14)),
          label: const Text(
            'Ver portfolio',
            style: TextStyle(fontSize: 13),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white70,
            side: const BorderSide(color: Color(0xFF333333)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  // ── MENSAJE PERSONAL ───────────────────────────────────────────────────────
  Widget _buildMensaje() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '👋 ¡Hola!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Hice esta app para ayudar a talleres técnicos a gestionar '
                'sus clientes, equipos y órdenes de forma simple y sin complicaciones.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Si te gustó, si encontraste un bug, o si querés pedirme una '
                'funcionalidad nueva, ¡escribime! Me encanta saber que la app '
                'le sirve a alguien. 🚀',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── CONTACTO ───────────────────────────────────────────────────────────────
  Widget _buildContacto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '💬 Contacto',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Email
        _ContactoTile(
          emoji: '📧',
          titulo: 'Email',
          subtitulo: _email,
          accionLabel: _emailCopiado ? '¡Copiado! ✓' : 'Copiar',
          accionColor: _emailCopiado
              ? const Color(0xFF3ECFCF)
              : const Color(0xFF6C63FF),
          onAccion: _copiarEmail,
        ),
      ],
    );
  }

  // ── REDES ──────────────────────────────────────────────────────────────────
  Widget _buildRedes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '🌐 Redes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _ContactoTile(
          emoji: '▶️',
          titulo: 'YouTube',
          subtitulo: 'Proyectos, consejos y más',
          accionLabel: 'Ver canal',
          accionColor: const Color(0xFFFF4444),
          onAccion: () => _abrirUrl(_youtube),
        ),
        const SizedBox(height: 8),
        _ContactoTile(
          emoji: '📸',
          titulo: 'Instagram',
          subtitulo: '@mau_developer',
          accionLabel: 'Seguir',
          accionColor: const Color(0xFFE1306C),
          onAccion: () => _abrirUrl(_instagram),
        ),
        const SizedBox(height: 8),
        _ContactoTile(
          emoji: '🎵',
          titulo: 'TikTok',
          subtitulo: '@maudeveloper',
          accionLabel: 'Ver',
          accionColor: const Color(0xFF3ECFCF),
          onAccion: () => _abrirUrl(_tiktok),
        ),
      ],
    );
  }

  // ── PIE ────────────────────────────────────────────────────────────────────
  Widget _buildPie() {
    return Column(
      children: [
        const Divider(color: Color(0xFF222222)),
        const SizedBox(height: 16),
        Text(
          'Hecho con ❤️ por MauDeveloper',
          style: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Gestión de Arreglos v1.1.0',
          style: TextStyle(
            color: Colors.white.withOpacity(0.2),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════
// TILE DE CONTACTO / RED SOCIAL
// ════════════════════════════════════════════
class _ContactoTile extends StatefulWidget {
  final String emoji;
  final String titulo;
  final String subtitulo;
  final String accionLabel;
  final Color accionColor;
  final VoidCallback onAccion;

  const _ContactoTile({
    required this.emoji,
    required this.titulo,
    required this.subtitulo,
    required this.accionLabel,
    required this.accionColor,
    required this.onAccion,
  });

  @override
  State<_ContactoTile> createState() => _ContactoTileState();
}

class _ContactoTileState extends State<_ContactoTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _hover ? const Color(0xFF222222) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hover ? const Color(0xFF333333) : const Color(0xFF242424),
          ),
        ),
        child: Row(
          children: [
            Text(widget.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitulo,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: widget.onAccion,
              style: TextButton.styleFrom(
                foregroundColor: widget.accionColor,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: widget.accionColor.withOpacity(0.3)),
                ),
              ),
              child: Text(
                widget.accionLabel,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}