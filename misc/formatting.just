# Prints a divider, with an intermediate message if a message argument is provided
divider MESSAGE="":
  @echo "--------------------------------------------------"
  @if [ -n "{{MESSAGE}}" ]; then \
    echo "--- {{MESSAGE}} ---"; \
  fi
  @echo "--------------------------------------------------"

