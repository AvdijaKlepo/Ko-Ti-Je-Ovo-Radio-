import 'package:flutter/material.dart';

class Notifications extends StatefulWidget {
  const Notifications({ required this.child, required this.notification, super.key});
  final Widget child;
  final Widget notification;

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  OverlayEntry? _overlayEntry;

  void _showNotification() {
    if( _overlayEntry ==null)
    {
      _showNotifications();
    } else{
      _hideNotifications();
    }
  }
  void _showNotifications() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy + renderBox.size.height,
        width: 250,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: widget.notification,
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideNotifications() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showNotification,
      child: widget.child,
    
    );
  }
}