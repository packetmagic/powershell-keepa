
. C:\temp\function-lib.ps1 # Update with your local path
$apiKey = 'YOUR-KEY' # Update with your key
$asins = Get-Content -Path "C:\temp\asin-list.txt" | Get-Unique # Update with path to your ASIN list
$asinOutput = 'C:\temp\full-asin-out-06-15-2022.txt' # Update with your desired output file path

foreach($asin in $asins){


    wait-for-keepa-tokens -apiKey $apiKey -numberOfTokens 100


    $sellerIDs = get-asin-sellers-keepa -apiKey $apiKey -asin $asin

    foreach($sellerID in $sellerIDs){


        get-all-seller-asins -sellerID $sellerID.sellerId -apiKey $apiKey -asinListPath $asinOutput



    }


}