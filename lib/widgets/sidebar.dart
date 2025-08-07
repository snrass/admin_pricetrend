import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../controllers/auth_controller.dart';
import '../components/button.dart';

class Sidebar extends StatelessWidget {
  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final String currentRoute = Get.currentRoute;

    return Container(
      width: 250,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          right: BorderSide(
            color: AppTheme.secondaryColor.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.secondaryColor.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.analytics_rounded,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'Fish Price Trend',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildMenuItem(
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  isActive: currentRoute == '/dashboard',
                  onTap: () => Get.toNamed('/dashboard'),
                ),
                _buildMenuItem(
                  icon: Icons.analytics_rounded,
                  title: 'Analytics',
                  isActive: currentRoute == '/analytics',
                  onTap: () => Get.toNamed('/analytics'),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppTheme.secondaryColor.withOpacity(0.2),
                ),
              ),
            ),
            child: CustomButton(
              variant: ButtonVariant.outline,
              onPressed: () => _showLogoutDialog(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppTheme.borderRadius,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: AppTheme.borderRadius,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : AppTheme.secondaryColor,
              size: 20,
            ),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : AppTheme.secondaryColor,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          CustomButton(
            variant: ButtonVariant.destructive,
            onPressed: () async {
              Get.back();
              await authController.signOut();
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
