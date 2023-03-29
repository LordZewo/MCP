function get-MCPDiceProbability {
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
    $diceSides = @('Blank', 'Blank', 'Hit', 'Hit', 'Skull', 'Wild', 'Block', 'Critical')

    # Define the success criteria based on the attack or defense rules
    if ($Attack) {
        $successCriteria = @('Hit')
    } elseif ($Defense) {
        if ($BlockOnBlanks) {
            $successCriteria = @('Block', 'Blank')
        } else {
            $successCriteria = @('Block')
        }
    } else {
        Write-Error "You must specify either the Attack or Defense switch."
        return
    }

    # Define the number of successes needed to count as a success
    if ($CountSkullAsSuccess) {
        $successCount = 1
    } else {
        $successCount = 2
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

    # Calculate the probability of failing all re-rolls
    $reRollFailureProbability = [Math]::Pow($failureProbability, $ReRoll)

    # Calculate the probability of succeeding at least once after re-rolls
    $reRollSuccessProbability = 1 - $reRollFailureProbability

    # Calculate the probability of succeeding at least once in the entire roll
    $totalSuccessProbability = $firstRollSuccessProbability * $reRollSuccessProbability

    # Calculate the expected number of successes in the entire roll
    $expectedSuccessCount = $totalSuccessProbability * $NumberOfDice

    # Format the output as a percentage
    $totalSuccessProbabilityPercent = '{0:P2}' -f $totalSuccessProbability
    $expectedSuccessCountPercent = '{0:N2}' -f $expectedSuccessCount

    # Return the results
    [PSCustomObject]@{
        TotalSuccessProbability = $totalSuccessProbabilityPercent
        ExpectedSuccessCount = $expectedSuccessCountPercent
    }

# Enables strict mode, which helps detect common coding errors
Set-StrictMode -Version Latest
# Sets the Tab key to the MenuComplete function, which provides tab-completion for parameter names
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
}
