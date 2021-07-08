# flutter_wizard_example

A wizard example based on FlowBuilder. The example comes with three
pages and an imaginary network service that affects the page order.

Structure:
- Welcome page
- Connect page (conditional)
- Summary page

Remarks:
- Pages call `Wizard.of(context).next()` to request the next page
- Pages do not know/care what comes next in the wizard
- Page order and routing logic is defined in one central place
- Adding, removing, or re-ordering pages does not cause changes in
  existing pages

