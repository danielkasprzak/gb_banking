--[[ MADE BY Nyxon#4418 ]]--


--[[ READ README INSTRUCTIONS CAREFULLY ]]--

-- PASTE THIS
function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
	AddTextEntry('FMMC_KEY_TIP1', TextEntry)
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
	blockinput = true

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait(0)
	end
		
	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		blockinput = false
		return result
	else
		Citizen.Wait(500)
		blockinput = false
		return ni
	end
end



-- COPY THIS AND REPLACE YOUR SHOP BUYING ACTION WITH IT
    local debitNumber = KeyboardInput("Debit card:", "Number", 14)
    if string.len(debitNumber) == 14 then
        local debitPIN = KeyboardInput("PIN code:", "PIN", 4)
        if string.len(debitPIN) == 4 then
            TriggerServerEvent('gb_bankingSHOP:login', debitNumber, debitPIN, data.current.item, data.current.value, zone)
        else
            ESX.ShowNotification('Please type your PIN code to debit card')
        end
    else
        ESX.ShowNotification('Please type your debit card number')
    end

--[[ MADE BY Nyxon#4418 ]]--