import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7D2AE8);
    const textDark = Color(0xFF1F1F2C);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0, // Mencegah warna berubah saat di-scroll
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87, size: 28),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: Colors.black87, size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          // 1. Kartu Profil Pengguna
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: purple,
                  child: Text(
                    'F',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Farrel Pratama',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'farrelpratama2109@gmail.com',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade700),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Grup Menu Utama (Ikon Ungu dalam Kotak)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildGroupedMenuItem(Icons.stars, 'Merek', purple, showBorder: true),
                _buildGroupedMenuItem(Icons.store_mall_directory_outlined, 'Katalog Cetak', purple, showBorder: true),
                _buildGroupedMenuItem(Icons.grid_view_rounded, 'Aplikasi', purple, showBorder: true),
                _buildGroupedMenuItem(Icons.auto_awesome, 'Lab Imajinasi', purple, showBorder: true),
                _buildGroupedMenuItem(Icons.campaign_outlined, 'Marketing', purple, showBorder: true),
                _buildGroupedMenuItem(Icons.school_outlined, 'Design School', purple, showBorder: false),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Daftar Menu Bawah (Ikon Hitam)
          _buildFlatMenuItem(Icons.person_outline_rounded, 'Akun Anda'),
          _buildFlatMenuItem(Icons.settings_outlined, 'Pengaturan'),
          _buildFlatMenuItem(Icons.delete_outline_rounded, 'Sampah'),
          _buildFlatMenuItem(Icons.contrast_rounded, 'Tema'),
          _buildFlatMenuItem(Icons.info_outline_rounded, 'Bantuan dan masukan'),
          _buildFlatMenuItem(Icons.apps_rounded, 'Alat lanjutan'),
          _buildFlatMenuItem(Icons.logout_rounded, 'Keluar', showTrailing: false),
          
          const SizedBox(height: 32), // Spasi kosong di paling bawah
        ],
      ),
    );
  }

  // Widget khusus untuk menu di dalam kotak
  Widget _buildGroupedMenuItem(IconData icon, String title, Color iconColor, {required bool showBorder}) {
    return Container(
      decoration: BoxDecoration(
        border: showBorder 
          ? Border(bottom: BorderSide(color: Colors.grey.shade200)) 
          : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Icon(icon, color: iconColor, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF1F1F2C),
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 24),
        onTap: () {},
      ),
    );
  }

  // Widget khusus untuk menu satuan di bawah
  Widget _buildFlatMenuItem(IconData icon, String title, {bool showTrailing = true}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: Icon(icon, color: Colors.black87, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF1F1F2C),
        ),
      ),
      trailing: showTrailing 
          ? const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 24)
          : null,
      onTap: () {},
    );
  }
}