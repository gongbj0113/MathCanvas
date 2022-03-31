import 'package:flutter/material.dart';

class ZoomableEditor extends StatefulWidget {
  const ZoomableEditor({Key? key}) : super(key: key);

  @override
  State<ZoomableEditor> createState() => _ZoomableEditorState();
}

class _ZoomableEditorState extends State<ZoomableEditor> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event){

        },
        child: MouseRegion(
          onEnter: (event){

          },
          onExit: (event){

          },
          onHover: (event){

          },
          child: GestureDetector(
            onTapDown: (details) {

            },
            onTapUp: (details){

            },
          ),
        ),
      ),
    );
  }
}
