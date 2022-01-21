### Name: Output a clickable link
### Description: Demonstrates how one could output a link, navigable by a mouse double click or from a context menu
### Compatibility: Sifon 1.2.5       
       
"."
"."
$Message  = @(
    "In order to return a navigable link that user could navigate by a mouse double click or from a dropdown context menu",
    "simply return this links as part of a new line. Please make sure there is nothing else on that line apart from URL itself",
    "",
    "In that case the output becomes a link and opens in a browser. Just try it double clicking the link located one line below",
    "",
    "https://sifon.uk/docs/QuickStart.md"
    );

Show-Message -Fore white -Back yellow -Text $Message
