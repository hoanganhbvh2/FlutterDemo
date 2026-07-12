import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/roadmap.dart';
import '../providers/roadmap_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? _selectedClassId;
  Student? _selectedStudent;
  final TextEditingController _passwordController = TextEditingController();
  String? _error;
  bool _loading = false;

  Color _parseHexColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.deepOrange;
    }
  }

  String _getShortName(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return parts.sublist(parts.length - 2).join(' ');
    }
    return fullName;
  }

  void _handleSelectStudent(Student student) {
    setState(() {
      _selectedStudent = student;
      _passwordController.clear();
      _error = null;
    });
  }

  void _handleSubmit(RoadmapProvider provider) {
    if (_selectedStudent == null) return;

    final enteredPassword = _passwordController.text;
    final correctPassword = _selectedStudent!.password.isEmpty ? "123" : _selectedStudent!.password;

    setState(() {
      _loading = true;
      _error = null;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (enteredPassword == correctPassword) {
        if (mounted) {
          provider.loginStudent(_selectedStudent!);
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Mật khẩu không khớp! Vui lòng nhập lại.';
            _loading = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RoadmapProvider>(context);
    final classes = provider.classes;
    final students = provider.students;

    final activeClass = classes.firstWhere(
      (c) => c.id == _selectedClassId,
      orElse: () => ClassGroup(id: '', name: '', code: '', room: '', createdAt: ''),
    );
    final classStudents = students.where((s) => s.classId == _selectedClassId).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Login Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        border: Border.all(color: const Color(0xFFFFEDD5)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.deepOrange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'CỔNG ĐĂNG NHẬP ẢNH',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Hệ Thống Xác Thực Sinh Viên',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              if (_selectedStudent == null) ...[
                // STEP 1: Select Classroom
                const Text(
                  'Bước 1: Chọn lớp của bạn',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.deepOrange,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedClassId,
                    hint: const Text(
                      '-- Chọn lớp học --',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.school_outlined, color: Colors.deepOrange, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.deepOrange),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    items: classes.map((c) {
                      return DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(
                          '${c.name} (${c.code})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedClassId = val;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // STEP 2: Portrait Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Bước 2: Chọn khuôn mặt của bạn',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.deepOrange,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    if (_selectedClassId != null && classStudents.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${classStudents.length} học viên',
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      )
                  ],
                ),
                const SizedBox(height: 12),

                if (_selectedClassId == null)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: const [
                        Text('🎓', style: TextStyle(fontSize: 24)),
                        SizedBox(height: 8),
                        Text(
                          'Chưa chọn lớp học',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Vui lòng chọn lớp học ở Bước 1 để hiển thị danh sách học viên.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 9, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                else if (classStudents.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: const [
                        Text('👥', style: TextStyle(fontSize: 24)),
                        SizedBox(height: 8),
                        Text(
                          'Lớp này chưa được thêm học viên.',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Hãy thêm học viên trong bảng điều khiển Admin!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 9, color: Colors.deepOrange, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: classStudents.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (context, index) {
                      final student = classStudents[index];
                      return GestureDetector(
                        onTap: () => _handleSelectStudent(student),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey.shade200, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.network(
                                      student.photoUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey.shade100,
                                          alignment: Alignment.center,
                                          child: Text(
                                            student.avatarEmoji,
                                            style: const TextStyle(fontSize: 24),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _parseHexColor(student.avatarColor),
                                      border: Border.all(color: Colors.white, width: 1.5),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      student.avatarEmoji,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _getShortName(student.name),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ] else ...[
                // STEP 3: Pin Password confirmation
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
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade100),
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    _selectedStudent!.photoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade100,
                                        alignment: Alignment.center,
                                        child: Text(
                                          _selectedStudent!.avatarEmoji,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _parseHexColor(_selectedStudent!.avatarColor),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _selectedStudent!.avatarEmoji,
                                    style: const TextStyle(fontSize: 8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'MSSV: ${_selectedStudent!.studentId}',
                                    style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedStudent!.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${activeClass.code} • ${activeClass.room}',
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Expanded(
                            child: Text(
                              'Nhập mật khẩu',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),

                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                          color: Color(0xFF1E293B),
                        ),
                        decoration: InputDecoration(
                          hintText: '••••',
                          hintStyle: const TextStyle(letterSpacing: 8),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.deepOrange),
                          ),
                        ),
                      ),

                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            border: Border.all(color: const Color(0xFFFECDD3)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Color(0xFFE11D48), size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: Color(0xFFBE123C),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedStudent = null;
                                  _error = null;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.refresh, size: 14, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(
                                    'Chọn lại ảnh',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _loading ? null : () => _handleSubmit(provider),
                              child: _loading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.check_circle_outline, size: 14, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text(
                                          'ĐĂNG NHẬP',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 36),
              // Humble Simple Footer
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Cổng đăng nhập học viên',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
