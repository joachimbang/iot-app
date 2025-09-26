import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:node_red_app/services/style.dart';
import 'package:node_red_app/utils/extension.dart';

class FormText extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final double? width;
  final bool? isHiden;
  final bool? isRequired;
  final bool? isSibmited;
  final List<TextInputFormatter>? inputFormatters;
  final bool? hasNotBorder;
  final int? maxLength;
  final TextInputType? keyboardType;
  final Icon? icon;
  const FormText({
    super.key,
    this.hint,
    this.controller,
    this.width,
    this.isHiden,
    this.isRequired,
    this.isSibmited,
    this.inputFormatters,
    this.hasNotBorder,
    this.maxLength,
    this.keyboardType,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    bool check =
        isRequired == true && isSibmited == true && controller!.text.isEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: hasNotBorder == true
            ? Theme.of(context).disabledColor.withOpacity(.5)
            : Colors.transparent,
        border: Border.all(
          width: .5,
          color: check
              ? AppStyle.ERROR
              : hasNotBorder == true
              ? Colors.transparent
              : Theme.of(context).disabledColor,
        ),
      ),
      child: TextField(
        keyboardType: keyboardType,
        style: Theme.of(context).textTheme.bodyMedium,
        inputFormatters: inputFormatters,
        controller: controller,
        maxLength: maxLength,
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          hintText: hint,
          hintStyle: Theme.of(context).textTheme.bodyMedium,
          suffixIcon: icon,
        ),
      ),
    );
  }
}

class FormPassWordText extends StatefulWidget {
  final String? hint;
  final bool? isRequired;
  final bool? isSibmited;
  final TextEditingController? controller;
  const FormPassWordText({
    super.key,
    this.hint,
    this.controller,
    this.isRequired,
    this.isSibmited,
  });

  @override
  State<FormPassWordText> createState() => _FormPassWordTextState();
}

class _FormPassWordTextState extends State<FormPassWordText> {
  ValueNotifier<bool> isObscure = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    bool check =
        widget.isRequired == true &&
        widget.isSibmited == true &&
        widget.controller!.text.isEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: check ? AppStyle.ERROR : Theme.of(context).disabledColor,
        ),
      ),
      child: ValueListenableBuilder(
        valueListenable: isObscure,
        builder: (context, bool isObscureText, child) {
          return Row(
            children: [
              Expanded(
                child: TextField(
                  style: Theme.of(context).textTheme.bodyMedium,
                  controller: widget.controller,
                  obscureText: isObscureText,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: widget.hint,
                    hintStyle: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              AppStyle.SPACING_XL.heightBox,
              InkWell(
                onTap: () {
                  isObscure.value = !isObscure.value;
                },
                child: Icon(
                  isObscureText ? Iconsax.eye : Iconsax.eye_slash,
                  size: 16,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
