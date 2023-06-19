import 'package:flutter/material.dart';

class AdaptiveButtons extends StatelessWidget {
  final String text;
  final void Function() handler;
  AdaptiveButtons(this.text,this.handler);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
                      onPressed: handler, 
                      child: Text(text,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      ),
                    );
  }
}