import 'package:flutter/material.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  
  const ResponsiveWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 화면 너비가 600px 이상이면 모바일 크기로 제한
        if (constraints.maxWidth > 600) {
          return Container(
            color: const Color(0xFFF1F5F9), // 외부 배경색 (연한 회색)
            child: Center(
              child: Container(
                width: 400, // 모바일 크기로 제한
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC), // 앱 배경색
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          );
        }
        
        // 모바일에서는 그대로 표시
        return child;
      },
    );
  }
}