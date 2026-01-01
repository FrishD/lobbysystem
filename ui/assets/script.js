var open = false;

window.addEventListener('message', function(event) {
    if (event.data.type === 'openmenu') {
        open = true;
        $(".root").css("display", "block");
        const checkbox = document.getElementById('color_mode');
        if (event.data.theme === 'dark') {
            checkbox.checked = true;
            applyDarkTheme();
        } else {
            checkbox.checked = false;
            applyLightTheme();
        }
    }
});

document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
        if (open) {
            Close();
        }
    }
});

function Close() {
    if (open) {
        open = false;
        $(".root").css("display", "none");
        saveCurrentTheme();
        fetch('https://ns-lobbysystem/close', {
            method: 'POST',
            body: JSON.stringify({})
        });
    }
}

document.addEventListener('DOMContentLoaded', () => {
    const options = document.querySelectorAll('.option-card');
    options.forEach(option => {
        const connectButton = option.querySelector('.connect-button');
        const lobbyInput = option.querySelector('.lobby-input');
        const teamSelection = option.querySelector('.team-selection');

        option.addEventListener('click', () => {
            if (option.id === 'zaira' || option.id === 'zakim') {
                if (teamSelection) teamSelection.style.display = 'block';
            } else {
                if (teamSelection) teamSelection.style.display = 'none';
            }
        });

        connectButton.addEventListener('click', () => {
            const lobbyNumber = lobbyInput.value;
            let team = null;

            if (!lobbyNumber) {
                alert("Please enter a lobby number.");
                return;
            }

            if (teamSelection && teamSelection.style.display !== 'none') {
                const selectedTeam = teamSelection.querySelector('input:checked');
                if (!selectedTeam) {
                    alert("Please select a team.");
                    return;
                }
                team = selectedTeam.value;
            }

            fetch('https://ns-lobbysystem/connect', {
                method: 'POST',
                body: JSON.stringify({
                    option: option.id,
                    lobby: lobbyNumber,
                    team: team
                })
            });
        });
    });

    const checkbox = document.getElementById('color_mode');
    checkbox.addEventListener('change', function () {
        if (this.checked) {
            applyDarkTheme();
        } else {
            applyLightTheme();
        }
    });

    // Initial state setup
    document.querySelectorAll('.team-selection').forEach(ts => {
        const parentId = ts.closest('.option-card').id;
        if (parentId !== 'zaira' && parentId !== 'zakim') {
            ts.style.display = 'none';
        }
    });
});


function saveCurrentTheme() {
    const checkbox = document.getElementById('color_mode');
    const theme = checkbox.checked ? 'dark' : 'light';
    fetch('https://ns-lobbysystem/settheme', {
        method: 'POST',
        body: JSON.stringify({ theme })
    });
}

window.addEventListener('message', function(event) {
    if (event.data.type === 'infos') {
        const avatarURL = event.data.steamfoto;
        const steamName = event.data.isim;
        console.log(avatarURL, steamName);
        $(".usercard-steamname").html('<div class="circlething" style="margin-top: 0.88vh; animation: none !important; opacity: 1;"><div class="circlething-inner"></div> </div>' + steamName);
        $(".usercard-steamphoto").attr("src", avatarURL);
    }
});

function applyDarkTheme() {
    $(".lobby-gradient").css("background", "linear-gradient(90deg, rgba(0, 0, 0, 0) 0%, rgb(14, 14, 14) 100%)");
    $(".usercard").css("background", "rgb(29, 29, 29)");
    $(".usercard").css("color", "white");
    $(".usercard").css("box-shadow", "0px 0px 88px -35px rgba(0,0,0,0.75)");
}

function applyLightTheme() {
    $(".lobby-gradient").css("background", "linear-gradient(90deg, rgba(0, 0, 0, 0) 0%, rgb(255, 255, 255) 100%)");
    $(".usercard").css("background", "white");
    $(".usercard").css("color", "black");
    $(".usercard").css("box-shadow", "none");
}
