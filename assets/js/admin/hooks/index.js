import AttachmentUrlInserter from './attachment_url_inserter';
import TextareaMutation from './textarea_mutation';

// https://hexdocs.pm/phoenix_live_view/js-interop.html#client-hooks-via-phx-hook
let Hooks = {};
Hooks.AttachmentUrlInserter = AttachmentUrlInserter;
Hooks.TextareaMutation = TextareaMutation;
export default Hooks;
