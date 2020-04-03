# Autostart-bash-script by twi

# DO NOT ACTIVATE THIS!
#. $GLOBALAUTOSTART


case "$HOSTNAME" in
    x1)
        xfce4-panel -d &
        ;;
    *)
        lxpanel&
        ;;
esac
