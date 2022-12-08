*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${FALSE}
Library     RPA.Excel.Files
Library     RPA.HTTP
Library     RPA.PDF
Library     RPA.Tables
Library     XML
Library     RPA.Robocloud.Secrets


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the intranet website
    Log In
    Download the Excel file
    Fill the forms
    Get the list of people from the CSV filess
    [Teardown]    Log out and Close


*** Keywords ***
Open the intranet website
    Open Available Browser    https://robotsparebinindustries.com/

Log In
    Input Text    username    maria
    Input Text    password    thoushallnotpass
    Submit Form
    Go To    https://robotsparebinindustries.com/#/robot-order
    Wait Until Page Contains Element    xpath://*[@id="root"]/div/div[2]/div/div
    Click Button    OK

Download the Excel file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Fill the forms
    ${people}=    Get the list of people from the CSV file
    FOR    ${person}    IN    @{people}
        Fill and submit the form    ${person}
    END

Get the list of people from the CSV file
    ${table}=    Read table from CSV    orders.csv    header=True
    RETURN    ${table}

Fill and submit the form
    [Arguments]    ${person}
    Select From List By Value    head    ${person}[Head]
    Wait And Click Button    id-body-${person}[Body]
    Input Text    address    ${person}[Address]
    Input Text    class:form-control    ${person}[Legs]
    Click Button    preview
    Wait Until Page Contains Element    robot-preview
    Sleep    4s

Screenshot
    Capture Element Screenshot
    ...    id:robot-preview-image
    ...    ${OUTPUT_DIR}${/}sales_results${/}sales_summary-${person}[Order number].png
    Wait Until Keyword Succeeds    10x    1s    Order

Html to PDF
    ${receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt}    ${OUTPUT_DIR}${/}sales_results${/}sales_results-${person}[Order number].pdf
    ${PDF}=    Open Pdf    ${OUTPUT_DIR}${/}sales_results${/}sales_results-${person}[Order number].pdf
    ${final}=    Add Watermark Image To Pdf
    ...    ${OUTPUT_DIR}${/}sales_results${/}sales_summary-${person}[Order number].png
    ...    ${OUTPUT_DIR}${/}sales_results${/}sales_results-${person}[Order number].pdf
    Close Pdf    ${PDF}
    ${final}=    Create List
    ...    ${OUTPUT_DIR}${/}sales_results${/}sales_results-${person}[Order number].pdf
    Add Files To Pdf    ${final}    ${OUTPUT_DIR}${/}sales_receipts.pdf    append=True

Another order
    Click Button    order-another
    Click Button    OK

Order
    Click Button    order
    Wait Until Page Contains Element    receipt

Log out and Close
    Click Button    logout
    Close Browser
