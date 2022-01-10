import 'package:flutter/material.dart';

class WizardAction {
  const WizardAction({required this.label, required this.onActivated});
  final String label;
  final VoidCallback? onActivated;
}

class WizardPage extends StatelessWidget {
  const WizardPage({
    Key? key,
    this.title,
    this.body,
    this.actions = const <WizardAction>[],
  }) : super(key: key);

  final Widget? title;
  final Widget? body;
  final List<WizardAction> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: title),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: body,
      ),
      bottomNavigationBar: Row(
        children: [
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ButtonBar(
              children: actions
                  .map(
                    (action) => OutlinedButton(
                      onPressed: action.onActivated,
                      child: Text(action.label),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class WizardCheckbox extends StatelessWidget {
  const WizardCheckbox({
    Key? key,
    this.title,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  final Widget? title;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: IntrinsicWidth(
        child: CheckboxListTile(
          tileColor: Colors.transparent,
          controlAffinity: ListTileControlAffinity.leading,
          title: title,
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
