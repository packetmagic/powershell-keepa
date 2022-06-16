### Function Library ##

function get-asin-sellers-keepa ($apiKey, $asin){


    $result = Invoke-WebRequest "https://api.keepa.com/product?key=$apiKey&domain=1&asin=$asin&offers=100" | ConvertFrom-Json

    return $result.products[0].offers | select -Property 'sellerId'



}


function get-keepa-tokens ($apiKey){


    $result = Invoke-WebRequest "https://api.keepa.com/token?key=$apiKey" | ConvertFrom-Json

    return $result



}


function wait-for-keepa-tokens($apiKey, $numberOfTokens){

    $tokens = get-keepa-tokens -apiKey $apiKey

    while ($tokens.tokensLeft -lt $numberOfTokens){

        $tokens = get-keepa-tokens -apiKey $apiKey
        Write-Host "Sleeping"
        Start-Sleep -Seconds 120

    }


}

function get-sellerId-from-deep-link ($link){

   $patternSeller = '(https:\/\/www.amazon.com\/dp\/(.*)\/)(\?m=)(\w+)(.*)'

   $link -match $patternSeller | Out-Null

   return $matches[4]



}

function combine-csvs ($folder, $outFolder){

    $date = Get-Date -Format MM-dd-yyyy


    Get-ChildItem -Path $folder -Filter *.csv | Select-Object -ExpandProperty FullName | Import-Csv | Export-Csv "$outFolder\merged-$date.csv" -NoTypeInformation -Append

    return "$outFolder\merged-$date.csv"



}

function get-all-seller-asins($sellerID, $apiKey, $asinListPath){
    $page = 0

    wait-for-keepa-tokens -apiKey $apiKey -numberOfTokens 100

    $query = @"
     {
         "sellerIds": [
                "$sellerId"
            ],
           "sort": [
                [
                    "current_SALES",
                    "asc"
                ]
                ],
            "lastOffersUpdate_gte": 6020436,
           "productType": [
              0,
              1
         ],
        "perPage": 100,
       "page": $page
     }
"@

    $result = Invoke-WebRequest "https://api.keepa.com/query?key=$apiKey&domain=1&selection=$query" | ConvertFrom-Json

    Add-Content -path $asinListPath $result.asinList

    if($result.totalResults -gt 100){

        $pages = $result.totalResults / 100

        while($page -lt $pages){
        
            wait-for-keepa-tokens -apiKey $apiKey -numberOfTokens 100

            $page++

            $query = @"
            {
              "sellerIds": [
                  "$sellerId"
               ],
               "sort": [
                  [
                      "current_SALES",
                      "asc"
                   ]
               ],
               "lastOffersUpdate_gte": 6020436,
               "productType": [
                 0,
                 1
               ],
             "perPage": 100,
              "page": $page
            }
"@

    $result = Invoke-WebRequest "https://api.keepa.com/query?key=$apiKey&domain=1&selection=$query" | ConvertFrom-Json

    Add-Content -path $asinListPath $result.asinList
        



    }


}

}