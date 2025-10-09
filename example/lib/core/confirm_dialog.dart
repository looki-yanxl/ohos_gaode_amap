import 'package:flutter/material.dart';

import 'anim_dialog.dart';

class ConfirmDialog extends StatefulWidget {
  const ConfirmDialog({
    Key? key,
    this.title = "标题",
    this.text = "消息",
    this.noCalBtn = false,
    this.surePass,
    this.cancelPass,
    this.sureBtnTx = "确认",
    this.cancelBtnTx = "取消",
    this.modBtnTx,
    this.backDismissible = true,
    this.modPass,
  }) : super(key: key);

  static show(context,
      {title = "标题",
      text = "消息",
      singBtn = false,
      sureBtnTx = "确认",
      cancelBtnTx = "取消",
      modBtnTx,
      barrierDismissible = true, //点击空白退出
      backDismissible = true, //点击回退键退出（设置此，空白退出会受影响，即设置后false后，点击空白也不会退出）
      surePass,
      modPass,
      cancelPass}) {
    showAnimationDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) {
          return ConfirmDialog(
            title: title,
            text: text,
            noCalBtn: singBtn,
            surePass: surePass,
            modPass: modPass,
            cancelPass: cancelPass,
            modBtnTx: modBtnTx,
            sureBtnTx: sureBtnTx,
            backDismissible: backDismissible,
            cancelBtnTx: cancelBtnTx,
          );
        });
  }

  final String title;
  final String text;
  final bool noCalBtn;
  final String sureBtnTx;
  final String? modBtnTx;
  final String cancelBtnTx;
  final VoidCallback? surePass;
  final VoidCallback? modPass;
  final VoidCallback? cancelPass;
  final bool backDismissible;

  @override
  State<StatefulWidget> createState() => ConfirmDialogState();
}

class ConfirmDialogState extends State<ConfirmDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.backDismissible) {
          return true;
        } else {
          return false;
        }
      },
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Card(
            margin: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                Text(widget.title, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 24),
                Container(
                  margin: const EdgeInsets.only(left: 15, right: 15),
                  width: double.infinity,
                  child: Text(widget.text, textAlign: TextAlign.center, style: const TextStyle(fontSize:16)),
                ),
                const SizedBox(height: 30),
                Container(height: 0.5, color: Colors.grey.withOpacity(0.2)),
                Row(
                  children: [
                    if (!widget.noCalBtn)
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: TextButton(
                            style: TextButton.styleFrom(backgroundColor: Colors.grey),
                            child: Text(widget.cancelBtnTx, style: const TextStyle( letterSpacing: 4, fontSize: 16)),
                            onPressed: () {
                              Navigator.pop(context);
                              if (widget.cancelPass != null) {
                                widget.cancelPass!();
                              }
                            },
                          ),
                        ),
                      ),
                    if (!widget.noCalBtn) Container(width: 0.5, height: 56, color: Colors.grey.withOpacity(0.2)),
                    if(widget.modBtnTx!=null && widget.modPass!=null)
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: TextButton(
                            child: Text(widget.modBtnTx!, style: const TextStyle(color: Colors.deepOrange,fontSize: 16)),
                            onPressed: () {
                              Navigator.pop(context);
                              widget.modPass!();
                            },
                          ),
                        ),
                      ),
                    if(widget.modBtnTx!=null && widget.modPass!=null) Container(width: 0.5, height: 56, color: Colors.grey.withOpacity(0.2)),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: TextButton(
                          child: Text(widget.sureBtnTx, style: const TextStyle(letterSpacing: 2, fontSize: 16)),
                          onPressed: () {
                            Navigator.pop(context);
                            if (widget.surePass != null) {
                              widget.surePass!();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
