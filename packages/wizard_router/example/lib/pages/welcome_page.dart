import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:wizard_router/wizard_router.dart';

import 'package:wizard_router_example/actions.dart';
import 'package:wizard_router_example/main.dart';
import 'package:wizard_router_example/widgets.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static Widget create(BuildContext context) => const WelcomePage();

  @override
  Widget build(BuildContext context) {
    return WizardPage(
      title: const Text('Welcome'),
      body: const Center(
        child: MarkdownBody(
          data: '''
# Welcome
This is an example implementation of a wizard based on `FlowBuilder`.
The example comes with two routes, whose order is determined by user
interaction and an imaginary network service.

## Routes:
- _Welcome -> Choice -> Preview_
- _Welcome -> Choice -> (Connect) -> Install_

## Remarks:
- Pages call `Wizard.of(context).next()` to request the next page.
- Pages do not know/care what comes next in the wizard (unless passing arguments
  that are assumed to be handled by the next page).
- Page order and routing logic is defined in one central place.
- Adding, removing, or re-ordering pages does not cause changes in existing
  pages.
''',
        ),
      ),
      actions: [
        WizardAction(
          label: 'Next',
          onActivated: () => WizardApp.useActions
              ? WizardNextIntent.invoke(context: context)
              : Wizard.of(context).next(),
        ),
      ],
    );
  }
}
