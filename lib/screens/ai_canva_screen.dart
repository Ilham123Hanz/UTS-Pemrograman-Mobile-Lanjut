import 'package:flutter/material.dart';

class AiCanvaScreen extends StatelessWidget {
  const AiCanvaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Membuat efek gradasi tipis dari atas ke tengah (cyan/ungu ke putih)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.4],
            colors: [
              Color(0xFFE8F1FF), // Warna kebiruan/ungu muda di atas
              Colors.white,      // Memudar jadi putih ke bawah
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Baris Ikon Atas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.pentagon_outlined, color: Colors.black87),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.view_sidebar_outlined, color: Colors.black87),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_square, color: Colors.black87),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              
              const Spacer(flex: 1),
              
              // 2. Teks Judul Sapaan dengan efek Gradasi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF0083B0), Color(0xFF6420C8)], // Gradasi Cyan ke Ungu
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Text(
                    'Mau mendesain apa\nhari ini, Farrel?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Harus putih agar ShaderMask terlihat
                      height: 1.2,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 3. Kotak Input AI yang bisa diketik
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        maxLines: 4, // Membuat kotak teks cukup besar ke bawah
                        decoration: InputDecoration(
                          hintText: 'Tugas apa yang harus kita selesaikan selanjutnya?',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                          border: InputBorder.none, // Menghilangkan garis bawaan TextField
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Ikon Plus dan Mic di dalam kotak input
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.black87),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.mic_none, color: Colors.black87),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}