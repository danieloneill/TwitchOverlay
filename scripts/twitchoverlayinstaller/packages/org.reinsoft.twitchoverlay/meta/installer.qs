function Component()
{
    // constructor
}

Component.prototype.createOperations = function()
{
    component.createOperations();
    if (systemInfo.productType === "windows") {
        component.addOperation("CreateShortcut", "@TargetDir@/TwitchOverlay.exe", "@StartMenuDir@/TwitchOverlay.lnk", "workingDirectory=@TargetDir@");
    }
}
