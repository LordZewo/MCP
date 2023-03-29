function Get-MCPDiceProbability {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]$NumberOfDice,

        [int]$ReRoll = 0,

        [Switch]$BlockOnBlanks,

        [Switch]$ReRollSkull,

        [Switch]$CountSkullAsSuccess,

        [Switch]$Attack,

        [Switch]$Defense
    )

    # Define the sides of the dice
    $diceSides = @('Blank', 'Blank', 'Hit', 'Hit','Block', 'Skull', 'Wild', 'Critical')

    # Define the success criteria based on the attack or defense rules
    if ($Attack) {
        if($CountSkullAsSuccess) {
            $successCriteria = @('Hit', 'Hit','Wild','Critical', 'Skull')
        } else {
            $successCriteria = @('Hit', 'Hit','Wild','Critical')
        }
    } elseif ($Defense) {
        if ($BlockOnBlanks) {
            $successCriteria = @('Block', 'Blank', 'Blank', 'Wild', 'Critical')
        }
        if($CountSkullAsSuccess){
            $successCriteria = @('Block', 'Wild', 'Critical', 'Skull')
        } else {
            $successCriteria = @('Block', 'Wild', 'Critical')
        }
    } else {
        Write-Error "You must specify either the Attack or Defense switch."
        return
    }

    # Calculate the probability of rolling a success on one die
    $successProbability = $successCriteria.Count / $diceSides.Count

    # Calculate the probability of rolling a failure on one die
    $failureProbability = 1 - $successProbability

    # Calculate the probability of rolling a critical success on the first roll
    $criticalProbability = $diceSides.Where({ $_ -eq 'Critical' }).Count / $diceSides.Count

    # Calculate the probability of rolling a success on the first roll
    $firstRollSuccessProbability = $successProbability + $criticalProbability * $successProbability

    # Calculate the probability of failing all rolls before re-rolls
    $firstRollFailureProbability = 1 - $firstRollSuccessProbability

    # Calculate the probability of succeeding all re-rolls
    if ($ReRoll -gt 0 -and $ReRollSkull) {
        $reRollSuccessProbability = ($successProbability + $criticalProbability * $successProbability + $failureProbability * $successProbability) * $ReRoll
    } else {
        $reRollSuccessProbability = ($successProbability + $criticalProbability * $successProbability) * $ReRoll
    }

    # Calculate the probability of failing all re-rolls
    $reRollFailureProbability = [Math]::Pow($failureProbability, $ReRoll)

    # Calculate the probability of succeeding at least once in the entire roll
    $totalSuccessProbability = $firstRollSuccessProbability + $reRollSuccessProbability * $firstRollFailureProbability

    # Calculate the expected number of successes in the entire roll
    $expectedSuccessCount = $totalSuccessProbability * $NumberOfDice

    # Format the output as a fraction
    $totalSuccessProbabilityFraction = [Math]::Round($totalSuccessProbability * $NumberOfDice, 0), '/', $NumberOfDice -join ''
    $firstRollFailureProbabilityFraction = [Math]::Round($firstRollFailureProbability * $NumberOfDice, 0), '/', $NumberOfDice -join ''


    # Return the results
    [PSCustomObject]@{
        SuccessCount = $totalSuccessProbabilityFraction
        ExpectedSuccess = $expectedSuccessCount
        FirstRollFailureCount = $firstRollFailureProbabilityFraction
    }

# Enables strict mode, which helps detect common coding errors
Set-StrictMode -Version Latest
# Sets the Tab key to the MenuComplete function, which provides tab-completion for parameter names
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
}

