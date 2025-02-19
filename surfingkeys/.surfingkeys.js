// Compatibility Prefix
const {
    Clipboard,
    Front,
    Hints,
    Normal,
    RUNTIME,
    Visual,
    aceVimMap,
    addSearchAlias,
    cmap,
    getClickableElements,
    imap,
    imapkey,
    iunmap,
    map,
    mapkey,
    readText,
    removeSearchAlias,
    tabOpenLink,
    unmap,
    unmapAllExcept,
    vmapkey,
    vunmap
} = api;

// Map H and L to switch between tabs
api.unmap('H');
api.map('H', 'E');
api.unmap('L');
api.map('L', 'R');
// Map J and K to move forward or backwards within a tab
api.unmap('J');
api.map('J', 'S');
api.unmap('K');
api.map('K', 'D');
