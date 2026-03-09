import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DriverSettingsScreen extends StatelessWidget {
  const DriverSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsSection('إعدادات العمل', [
            _buildSwitchTile(Icons.delivery_dining, 'حالة التوفر', true, (v) {}),
            _buildSettingsTile(Icons.map, 'منطقة العمل', () {}),
            _buildSettingsTile(Icons.directions_car, 'معلومات المركبة', () {}),
          ]),
          const SizedBox(height: 16),
          _buildSettingsSection('الإشعارات', [
            _buildSwitchTile(Icons.notifications, 'إشعارات الطلبات', true, (v) {}),
            _buildSwitchTile(Icons.volume_up, 'صوت الإشعارات', true, (v) {}),
          ]),
          const SizedBox(height: 16),
          _buildSettingsSection('الأمان', [
            _buildSettingsTile(Icons.lock, 'تغيير كلمة المرور', () {}),
            _buildSettingsTile(Icons.security, 'التحقق الثنائي', () {}),
          ]),
          const SizedBox(height: 16),
          _buildSettingsSection('الدعم', [
            _buildSettingsTile(Icons.help, 'المساعدة', () {}),
            _buildSettingsTile(Icons.info, 'عن التطبيق', () {}),
          ]),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
    );
  }
}
