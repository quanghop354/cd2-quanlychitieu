import 'package:flutter/material.dart';

void main() {
  runApp(const ExpenseManagerApp());
}

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const RootNavigation(),
    );
  }
}

// Lớp điều phối chính: Kiểm tra xem hiển thị trang Auth hay trang Main
class RootNavigation extends StatefulWidget {
  const RootNavigation({super.key});

  @override
  State<RootNavigation> createState() => _RootNavigationState();
}

class _RootNavigationState extends State<RootNavigation> {
  bool _isLoggedIn = false;

  // Thông tin người dùng (Có thể lưu vào database sau này)
  String _name = "Hoàng Quang Hợp";
  String _dob = "30/05/2004";
  String _email = "quanghop3054@gmail.com";
  String _phone = "0999999999";

  void _login() => setState(() => _isLoggedIn = true);
  void _logout() => setState(() => _isLoggedIn = false);

  void _updateProfile(String name, String dob, String email, String phone) {
    setState(() {
      _name = name;
      _dob = dob;
      _email = email;
      _phone = phone;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return AuthScreen(onLoginSuccess: _login);
    }
    return MainNavigationScreen(
      name: _name,
      dob: _dob,
      email: _email,
      phone: _phone,
      onLogout: _logout,
      onUpdateProfile: _updateProfile,
    );
  }
}

// --- TRANG ĐĂNG NHẬP / ĐĂNG KÝ (RIÊNG BIỆT) ---
class AuthScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const AuthScreen({super.key, required this.onLoginSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade800, Colors.deepPurple.shade400],
            begin: Alignment.topCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 80),
            const Icon(Icons.account_balance_wallet, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              _isLoginView ? "Chào mừng trở lại" : "Tạo tài khoản mới",
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTextField(Icons.email_outlined, "Email"),
                      if (!_isLoginView) ...[
                        const SizedBox(height: 15),
                        _buildTextField(Icons.person_outline, "Họ và tên"),
                      ],
                      const SizedBox(height: 15),
                      _buildTextField(Icons.lock_outline, "Mật khẩu", obscure: true),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: widget.onLoginSuccess,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: Text(_isLoginView ? "ĐĂNG NHẬP" : "ĐĂNG KÝ"),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _isLoginView = !_isLoginView),
                        child: Text(_isLoginView ? "Chưa có tài khoản? Đăng ký ngay" : "Đã có tài khoản? Đăng nhập"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hint, {bool obscure = false}) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}

// --- GIAO DIỆN CHÍNH (CHỈ HIỆN KHI ĐÃ ĐĂNG NHẬP) ---
class MainNavigationScreen extends StatefulWidget {
  final String name, dob, email, phone;
  final VoidCallback onLogout;
  final Function(String, String, String, String) onUpdateProfile;

  const MainNavigationScreen({
    super.key,
    required this.name,
    required this.dob,
    required this.email,
    required this.phone,
    required this.onLogout,
    required this.onUpdateProfile,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      const ExpenseDashboard(),
      const Center(child: Text('Thống kê')),
      const Center(child: Text('Ví')),
      _buildProfileTab(),
    ];

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Thống kê'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Ví'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    int age = _calculateAge(widget.dob);
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInfoCard(Icons.cake, "Ngày sinh", "${widget.dob} ($age tuổi)"),
                _buildInfoCard(Icons.email, "Email", widget.email),
                _buildInfoCard(Icons.phone, "Số điện thoại", widget.phone),
                const SizedBox(height: 30),
                _buildActionButton(Icons.edit, "Chỉnh sửa thông tin", Colors.deepPurple, _showEditDialog),
                const SizedBox(height: 12),
                _buildActionButton(Icons.logout, "Đăng xuất", Colors.red, widget.onLogout),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 18,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, size: 16, color: Colors.deepPurple),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tính năng đổi ảnh đang phát triển!")));
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(widget.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const Text('Thành viên Vàng', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color),
        label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  void _showEditDialog() {
    final nameCont = TextEditingController(text: widget.name);
    final dobCont = TextEditingController(text: widget.dob);
    final emailCont = TextEditingController(text: widget.email);
    final phoneCont = TextEditingController(text: widget.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Chỉnh sửa thông tin"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCont, decoration: const InputDecoration(labelText: "Họ và tên")),
              TextField(controller: dobCont, decoration: const InputDecoration(labelText: "Ngày sinh (dd/mm/yyyy)")),
              TextField(controller: emailCont, decoration: const InputDecoration(labelText: "Email")),
              TextField(controller: phoneCont, decoration: const InputDecoration(labelText: "Số điện thoại")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              widget.onUpdateProfile(nameCont.text, dobCont.text, emailCont.text, phoneCont.text);
              Navigator.pop(context);
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  int _calculateAge(String dob) {
    try {
      final parts = dob.split('/');
      final birth = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      int age = DateTime.now().year - birth.year;
      if (DateTime.now().isBefore(DateTime(DateTime.now().year, birth.month, birth.day))) age--;
      return age;
    } catch (_) { return 0; }
  }
}

// --- DASHBOARD (GIỮ NGUYÊN) ---
class ExpenseDashboard extends StatelessWidget {
  const ExpenseDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('Quản lý chi tiêu', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: const Center(child: Text("Nội dung trang chủ")),
    );
  }
}
