
$(document).ready(function () {
    let currentGamedata = null;
    let selectedGameMode = null;

    // Function to switch between views
    function switchView(viewId) {
        $('.view').removeClass('active');
        $('#' + viewId).addClass('active');
    }

    // Populate Game Modes
    function populateGameModes(gameModes) {
        const container = $('#game-modes-container');
        container.empty();
        for (const [key, mode] of Object.entries(gameModes)) {
            const card = $(`
                <div class="game-mode-card" data-mode="${key}">
                    <h3>${mode.Label}</h3>
                    <p>${mode.Description}</p>
                </div>
            `);
            card.on('click', function() {
                selectedGameMode = key;
                prepareLobbyDetails(key, mode);
                switchView('lobby-details');
            });
            container.append(card);
        }
    }

    // Prepare Lobby Details View
    function prepareLobbyDetails(modeKey, modeData) {
        $('#lobby-title').text(`${modeData.Label} Lobby`);

        // Handle Team Selection
        if (modeData.Settings.TeamSelection) {
            $('#team-selection').show();
        } else {
            $('#team-selection').hide();
        }

        // Handle Weapon Selection
        const weaponSelect = $('#weapon-select');
        if (modeData.Settings.WeaponSelection) {
            $('#weapon-selection').show();
            weaponSelect.empty();
            modeData.Settings.Weapons.forEach(weapon => {
                weaponSelect.append(`<option value="${weapon.hash}">${weapon.name}</option>`);
            });
        } else {
            $('#weapon-selection').hide();
        }

        // For Ramps, Lobby ID is not needed for bucket selection server-side
        if (modeKey === 'Ramps') {
            $('#lobby-id-input').attr('placeholder', 'Enter a lobby number (optional)');
        } else {
            $('#lobby-id-input').attr('placeholder', 'Lobby ID');
        }
    }

    // NUI Message Listener
    window.addEventListener('message', function(event) {
        if (event.data.type === 'openmenu') {
            currentGamedata = event.data.data;
            populateGameModes(currentGamedata.GameModes);
            if (event.data.steaminfo) {
                 $(".usercard-steamname").html('<div class="circlething" style="margin-top: 0.88vh; animation: none !important; opacity: 1;"><div class="circlething-inner"></div> </div>' + event.data.steaminfo.isim);
                 $(".usercard-steamphoto").attr("src", event.data.steaminfo.steamfoto);
            }
            $('.root').fadeIn(500);
            switchView('game-mode-selection');
        }
    });

    // Back Button
    $('#back-button').on('click', function() {
        switchView('game-mode-selection');
        $('#lobby-id-input').val(''); // Clear input
    });

    // Close Button & Escape Key
    function closeMenu() {
        $('.root').fadeOut(500);
        $.post(`https://ns-lobbysystem/close`, JSON.stringify({}));
    }

    $('#close-button').on('click', closeMenu);
    $(document).on('keydown', function(e) {
        if (e.key === "Escape") {
            closeMenu();
        }
    });

    // Connect Button
    $('#connect-button').on('click', function() {
        const lobbyId = $('#lobby-id-input').val();

        if (selectedGameMode !== 'Ramps' && (!lobbyId || isNaN(lobbyId) || lobbyId.trim() === '')) {
            // Simple validation: Ensure lobbyId is a number for modes that require it.
            console.log("Invalid Lobby ID");
            return;
        }

        const connectionData = {
            gameMode: selectedGameMode,
            lobbyId: parseInt(lobbyId) || null, // Send null if empty/invalid
            team: $('input[name="team"]:checked').val(),
            weapon: $('#weapon-select').val()
        };

        $.post(`https://ns-lobbysystem/connect`, JSON.stringify(connectionData));
        closeMenu();
    });
});
